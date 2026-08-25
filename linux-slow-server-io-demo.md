# Linux Server Is Slow but CPU Is Low: Reproducible I/O Bottleneck Demo

This lab creates a **safe, synthetic Linux storage bottleneck** inside an Oracle VirtualBox VM.

The goal is to reproduce a common troubleshooting pattern:

```text
The server feels slow
        +
CPU usage is not high
        +
Load / blocked work may increase
        +
Disk latency and queueing are high
        =
The workload is waiting on storage
```

This is useful for learning and demonstrations of:

- Linux load average
- I/O wait
- blocked tasks
- `D` state processes
- disk latency and queue depth
- `iostat`
- `vmstat`
- Linux PSI
- `fio`

> **Warning**
>
> Use a throwaway lab VM.
>
> The partitioning and `mkfs` commands in this guide **erase the selected disk**.
>
> Never copy the device name blindly. Verify the demo disk with `lsblk` first.
>
> Do not run the stress workload on production systems.

---

## Architecture

Example lab:

```text
Windows host
└── Oracle VirtualBox
    └── Ubuntu VM
        ├── OS disk
        │   └── normal speed
        │
        └── demo disk
            ├── 10 GiB VDI
            ├── VirtualBox bandwidth group
            └── intentionally limited to 5 MiB/s
```

The host can use NVMe storage. The demo disk is still intentionally constrained by VirtualBox.

---

# Part 1: Create the Slow Virtual Disk

Run these commands in **Windows PowerShell**, not inside Linux.

Set reusable variables first:

```powershell
$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"
$VMName = "YOUR_VM_NAME"
$VMDir = "C:\Path\To\Your\VirtualBox VM"
$SlowDisk = Join-Path $VMDir "SlowDisk.vdi"
```

Replace:

```text
YOUR_VM_NAME
```

and:

```text
C:\Path\To\Your\VirtualBox VM
```

with your own values.

---

## 1. Power Off the VM

The VM should be fully powered off before creating the bandwidth group or attaching the disk.

Check running VMs:

```powershell
& $VBoxManage list runningvms
```

Your lab VM should not appear in the output.

---

## 2. Make Sure the SATA Controller Has Another Port

This example allows two SATA ports:

```powershell
& $VBoxManage storagectl $VMName `
  --name "SATA" `
  --portcount 2
```

If your VM already has enough ports, this may not be necessary.

---

## 3. Create a 10 GiB VDI

```powershell
& $VBoxManage createmedium disk `
  --filename $SlowDisk `
  --size 10240 `
  --format VDI
```

Explanation:

```text
--filename
    Path of the new virtual disk.

--size 10240
    Disk capacity in MiB.
    10240 MiB = 10 GiB.

--format VDI
    Creates a VirtualBox Disk Image.
```

This does **not** make the disk slow by itself.

The bandwidth group in the next step does that.

---

## 4. Create a Disk Bandwidth Group

Create a bandwidth group limited to **5 MiB/s**:

```powershell
& $VBoxManage bandwidthctl $VMName add SlowDiskLimit `
  --type disk `
  --limit 5M
```

Verify:

```powershell
& $VBoxManage bandwidthctl $VMName list
```

Expected shape:

```text
Name: SlowDiskLimit
Type: Disk
Limit: 5 MiB/s
```

Oracle VirtualBox uses bandwidth groups to limit maximum bandwidth for asynchronous disk I/O.

The configured value is a **ceiling**, not a promise that the workload will always achieve exactly that throughput.

---

## 5. Attach the New Disk to SATA Port 1

```powershell
& $VBoxManage storageattach $VMName `
  --storagectl "SATA" `
  --port 1 `
  --device 0 `
  --type hdd `
  --medium $SlowDisk `
  --bandwidthgroup SlowDiskLimit
```

This attaches only the new demo disk to `SlowDiskLimit`.

Your OS disk should remain unrestricted.

---

## 6. Verify the VirtualBox Configuration

```powershell
& $VBoxManage showvminfo $VMName --machinereadable |
    Select-String -Pattern 'SATA|SlowDisk|Bandwidth'
```

You should see the new VDI on the additional SATA port and a bandwidth group similar to:

```text
BandwidthGroup0="SlowDiskLimit",Disk,5242880
```

`5242880` bytes per second is 5 MiB/s.

---

# Part 2: Prepare the Disk Inside Linux

Start the VM.

Run the following commands **inside Ubuntu/Linux**.

---

## 1. Identify the New Disk

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
```

Example:

```text
sda      100G disk
└─sda2   100G part ext4  /

sdb       10G disk
```

In this example:

```text
/dev/sda = OS disk
/dev/sdb = new 10 GiB demo disk
```

> **STOP AND VERIFY**
>
> Your device name may be different.
>
> The next commands destroy existing data on the selected disk.

For the rest of this guide, `/dev/sdb` is used as an example.

---

## 2. Create a GPT Partition Table and One Partition

```bash
sudo parted /dev/sdb --script mklabel gpt
sudo parted /dev/sdb --script mkpart primary ext4 0% 100%
sudo partprobe /dev/sdb
```

Verify:

```bash
lsblk
```

Expected shape:

```text
sdb      10G disk
└─sdb1   10G part
```

---

## 3. Create an ext4 Filesystem

```bash
sudo mkfs.ext4 -L slowdisk /dev/sdb1
```

Explanation:

```text
mkfs.ext4
    Creates an ext4 filesystem.

-L slowdisk
    Gives the filesystem a human-readable label.

 /dev/sdb1
    The demo partition.
```

---

## 4. Mount It

```bash
sudo mkdir -p /mnt/slowdisk
sudo mount /dev/sdb1 /mnt/slowdisk
sudo chown "$USER":"$USER" /mnt/slowdisk
```

Verify:

```bash
lsblk -f
df -h /mnt/slowdisk
```

---

# Part 3: Install the Troubleshooting Tools

Ubuntu / Debian:

```bash
sudo apt update
sudo apt install -y fio sysstat
```

Tools used in this lab:

```text
fio
    Generates controlled storage workloads.

top
    Shows CPU, load average, processes, and I/O wait.

vmstat
    Shows runnable tasks, blocked tasks, CPU state, and I/O activity.

iostat
    Shows per-device throughput, queueing, utilization, and latency.

ps
    Lets us inspect process state.

Linux PSI
    Shows resource pressure and stalled work.
```

---

# Part 4: Validate the Slow Disk with fio

## Why fio Instead of dd?

VirtualBox documents its disk bandwidth control as a limit on **asynchronous I/O**.

A simple `dd` test may therefore not demonstrate the configured bandwidth group the way you expect.

For this lab, use `fio` with Linux asynchronous I/O.

---

## Validation Workload

A smaller file is convenient because an intentionally slow disk can take a long time to prepare a large test file.

```bash
fio \
  --name=vbox-limit-test \
  --filename=/mnt/slowdisk/fio-test \
  --size=256M \
  --rw=write \
  --bs=1M \
  --ioengine=libaio \
  --iodepth=32 \
  --direct=1 \
  --runtime=30 \
  --time_based \
  --group_reporting
```

### What Each fio Option Means

#### `--name=vbox-limit-test`

Names the fio job.

It is only a label used in output.

---

#### `--filename=/mnt/slowdisk/fio-test`

Tells fio which file to use for I/O.

The file is on the intentionally slow disk.

---

#### `--size=256M`

Defines the size of the test area.

For a demo, 256 MiB keeps setup time reasonable on a throttled disk.

You can increase this if needed.

---

#### `--rw=write`

Generates sequential writes.

---

#### `--bs=1M`

Uses 1 MiB I/O blocks.

A single I/O request is therefore 1 MiB.

IOPS numbers always need to be interpreted together with block size.

For example, 3 IOPS with 1 MiB writes is very different from 3 IOPS with 4 KiB writes.

---

#### `--ioengine=libaio`

Uses Linux native asynchronous I/O through `libaio`.

This allows fio to have multiple requests outstanding instead of waiting for every request to finish before submitting the next one.

---

#### `--iodepth=32`

Requests a queue depth of up to 32 outstanding I/O operations.

Conceptually:

```text
request 1  ─┐
request 2   │
request 3   │
...         ├── waiting for storage
request 32 ─┘
             ↓
          slow disk
```

fio's final `IO depths` section shows the queue depths that were actually achieved.

---

#### `--direct=1`

Uses direct I/O.

This avoids normal buffered page-cache behavior from hiding the storage bottleneck.

It is also important when using `libaio` if you want asynchronous behavior with queue depth greater than 1 on Linux.

---

#### `--runtime=30`

Limits the timed workload to 30 seconds.

---

#### `--time_based`

Makes fio continue the workload for the configured runtime even if it reaches the end of the configured test area.

---

#### `--group_reporting`

Reports aggregate statistics for the job group.

This becomes especially useful when `numjobs` is greater than 1.

---

# Part 5: Read the Important fio Output

A fio result may contain many fields.

For this troubleshooting demo, focus on a small set.

---

## 1. Bandwidth

Example shape:

```text
write: IOPS=..., BW=...
```

`BW` is throughput.

For example:

```text
BW=3400KiB/s
```

is about:

```text
3.3 MiB/s
```

The bandwidth group's 5 MiB/s value is a maximum limit.

Actual throughput can be lower.

---

## 2. IOPS

```text
IOPS=...
```

IOPS means I/O operations per second.

Always interpret it together with:

```text
--bs
```

A workload with 1 MiB operations naturally completes far fewer IOPS than a workload with 4 KiB operations at the same throughput.

Do not describe the result as the disk's universal IOPS capability.

Describe it as the IOPS for **this workload**.

---

## 3. Submission Latency

```text
slat
```

`slat` is submission latency.

It measures the time fio spends getting an I/O submitted.

---

## 4. Completion Latency

```text
clat
```

`clat` is completion latency.

It measures the time from I/O submission until fio sees that I/O complete.

This is usually one of the most useful values in this demo.

When a throttled device is heavily queued, completion latency can become very large.

Do not describe this as raw physical media latency.

It includes the effects of the entire queued workload.

---

## 5. Total Latency

```text
lat
```

Total latency is approximately:

```text
slat + clat
```

---

## 6. Latency Percentiles

fio also reports percentiles such as:

```text
50.00th
90.00th
95.00th
99.00th
```

These are useful because averages can hide painful tail latency.

For example:

```text
P50 = typical/median completion time
P95 = 95% completed at or below this value
P99 = tail latency
```

Use the actual numbers from your own run.

---

## 7. fio CPU Usage

Example shape:

```text
cpu : usr=..., sys=...
```

Important:

These are CPU statistics for the **fio job**.

They are not the CPU utilization of the entire Linux machine.

Use `top` or `vmstat` to discuss system-wide CPU usage.

---

## 8. I/O Depth Distribution

Example:

```text
IO depths:
1=...
2=...
4=...
8=...
16=...
32=...
```

This tells you whether fio actually achieved the requested queue depth.

If most of the workload is at depth 32, the queue remained heavily populated.

---

## 9. Device Utilization

At the bottom of the fio output you may see:

```text
Disk stats (read/write):
  sdb: ... util=...
```

A value near 100% means the device had I/O in progress and was busy for nearly the entire observed interval.

Do not automatically interpret `%util` as "percentage of the disk's total performance capacity."

That interpretation can be misleading, especially with parallel storage.

---

# Part 6: Create the Actual Incident

The validation workload proves the throttled disk works.

For a more obvious troubleshooting scenario, use smaller random I/O and more concurrency.

```bash
fio \
  --name=incident \
  --filename=/mnt/slowdisk/incident-file \
  --size=512M \
  --rw=randwrite \
  --bs=4k \
  --ioengine=libaio \
  --iodepth=64 \
  --numjobs=8 \
  --direct=1 \
  --runtime=180 \
  --time_based \
  --group_reporting
```

Explanation:

```text
--rw=randwrite
    Random writes instead of sequential writes.

--bs=4k
    Small 4 KiB operations.

--iodepth=64
    Up to 64 outstanding I/Os per job.

--numjobs=8
    Runs eight copies of the workload.

--runtime=180
    Keeps the incident running long enough to investigate it.
```

This is intentionally aggressive.

The goal is not to model every production workload.

The goal is to create a repeatable lab where storage becomes the obvious bottleneck.

---

# Part 7: Investigate While fio Is Running

Open separate terminals while the incident workload is active.

---

## 1. Start with `top`

```bash
top
```

Look at:

```text
load average
%us
%sy
%wa
%id
```

### What They Mean

```text
%us
    CPU time running user-space code.

%sy
    CPU time running kernel code.

%wa
    CPU idle time while outstanding disk I/O exists.

%id
    CPU idle time.
```

The interesting pattern for this lab is:

```text
machine feels slow
CPU not saturated
storage activity / waiting is obvious
```

Do not force the conclusion from one metric.

Use the rest of the tools to confirm it.

---

## 2. Check Load Average

You can see it in `top`, or run:

```bash
uptime
```

Example shape:

```text
load average: 8.12, 4.10, 1.80
```

The three values are approximately the:

```text
1-minute
5-minute
15-minute
```

load averages.

Linux load average includes runnable tasks and tasks in uninterruptible sleep.

That is why load can be high even when CPU usage is not high.

---

## 3. Check Runnable and Blocked Tasks with `vmstat`

```bash
vmstat 1
```

Important columns:

```text
r
    Tasks runnable or waiting to run on CPU.

b
    Tasks blocked in uninterruptible sleep.

wa
    CPU I/O-wait percentage.
```

If `b` is elevated during the incident, it is a clue that work is blocked waiting for something such as I/O.

---

## 4. Look for `D` State Processes

```bash
ps -eo state,pid,comm,wchan:32 | grep '^D'
```

Or watch continuously:

```bash
watch -n 0.5 "ps -eo state,pid,comm,wchan:32 | grep '^D'"
```

`D` means uninterruptible sleep.

Storage I/O is a common cause, but not the only possible cause.

Do not say:

```text
D state always means disk problem.
```

A safer statement is:

```text
D state means the task is waiting uninterruptibly in the kernel.
Storage or filesystem I/O is a common reason.
```

Also note that an asynchronous fio workload does not guarantee that many user processes will visibly remain in `D` state.

Measure what your run actually shows.

---

## 5. Inspect the Disk with `iostat`

```bash
iostat -xz 1
```

Find the demo device, for example:

```text
sdb
```

Useful fields may include:

```text
r/s, w/s
    Read/write operations per second.

rkB/s, wkB/s
    Throughput.

r_await, w_await
    Average read/write request latency in milliseconds.

aqu-sz
    Average queue size.

%util
    Percentage of time I/O was in progress for the device.
```

Field names can vary slightly by `sysstat` version.

The strongest evidence usually comes from combining:

```text
high await
+
large queue
+
high device activity
+
slow application behavior
```

---

## 6. Check Linux PSI

Pressure Stall Information:

```bash
cat /proc/pressure/io
```

Example shape:

```text
some avg10=... avg60=... avg300=... total=...
full avg10=... avg60=... avg300=... total=...
```

### `some`

At least one task is stalled on I/O.

### `full`

All non-idle tasks are simultaneously stalled on I/O.

PSI helps answer a useful question:

```text
How much is resource pressure preventing workloads from making progress?
```

That can be more informative than looking only at CPU utilization.

---

# Part 8: A Simple Troubleshooting Flow

When a Linux machine is slow but CPU is not obviously saturated:

```text
1. Confirm the symptom
        ↓
2. Check CPU + load
        top
        ↓
3. Check runnable / blocked work
        vmstat 1
        ↓
4. Look for D state
        ps ...
        ↓
5. Inspect storage
        iostat -xz 1
        ↓
6. Check pressure
        /proc/pressure/io
        ↓
7. Correlate the evidence
```

The key question is:

```text
What is the workload waiting for?
```

---

# Part 9: Useful Commands at a Glance

## Identify disks

```bash
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
```

## Filesystem usage

```bash
df -h
```

## CPU, processes, and load

```bash
top
```

## Uptime and load average

```bash
uptime
```

## Runnable / blocked tasks and CPU state

```bash
vmstat 1
```

## D-state tasks

```bash
ps -eo state,pid,comm,wchan:32 | grep '^D'
```

## Device I/O statistics

```bash
iostat -xz 1
```

## I/O pressure

```bash
cat /proc/pressure/io
```

## Repeated PSI output

```bash
watch -n 1 'cat /proc/pressure/io'
```

## Repeated D-state check

```bash
watch -n 0.5 "ps -eo state,pid,comm,wchan:32 | grep '^D'"
```

---

# Part 10: Stop and Clean Up the Lab

Stop fio with:

```text
Ctrl+C
```

Remove test files:

```bash
rm -f /mnt/slowdisk/fio-test
rm -f /mnt/slowdisk/incident-file
```

Unmount the demo filesystem:

```bash
sudo umount /mnt/slowdisk
```

If you want to detach the demo disk, power off the VM first and run from PowerShell:

```powershell
& $VBoxManage storageattach $VMName `
  --storagectl "SATA" `
  --port 1 `
  --device 0 `
  --type hdd `
  --medium none
```

Remove the bandwidth group after nothing references it:

```powershell
& $VBoxManage bandwidthctl $VMName remove SlowDiskLimit
```

Delete the VDI only if you no longer need it:

```powershell
Remove-Item $SlowDisk
```

Be certain `$SlowDisk` points to the disposable demo disk before deleting anything.

---

# Important Accuracy Notes

## High Load Does Not Mean High CPU

Linux load average is not a CPU-utilization percentage.

Tasks that are runnable and tasks waiting in uninterruptible sleep contribute to load.

---

## Low CPU Does Not Mean the System Is Healthy

A process can be slow because it spends most of its time waiting for:

```text
storage
network filesystems
locks
memory reclaim
other kernel resources
```

This lab intentionally demonstrates storage.

---

## `D` State Is a Clue, Not a Root Cause

`D` means uninterruptible sleep.

You still need to investigate what the task is waiting on.

---

## `%util` Is Not "Percent of Performance Used"

A device near 100% utilization was busy almost continuously during the measurement interval.

That does not necessarily mean you have mathematically consumed 100% of every capability of the storage system.

---

## fio Latency Is Workload Latency

If fio reports very large completion latency while the queue is saturated, that latency includes queueing and the full storage path.

Do not describe it as the bare physical latency of the disk media.

---

# Official References

- Oracle VirtualBox User Manual: Virtual Storage and Disk Bandwidth Limiting  
  https://docs.oracle.com/en/virtualization/virtualbox/7.2/user/storage.html

- Oracle VirtualBox `VBoxManage` Documentation  
  https://docs.oracle.com/en/virtualization/virtualbox/7.1/user/vboxmanage.html

- fio Documentation  
  https://fio.readthedocs.io/en/latest/fio_doc.html

- fio Source and HOWTO  
  https://github.com/axboe/fio

---

# Why This Lab Exists

This lab is designed around one troubleshooting lesson:

> A Linux server can feel extremely slow while CPU usage remains low because the workload is spending its time waiting rather than computing.

The goal is not to memorize commands.

The goal is to correlate evidence and find the resource that is preventing the workload from making progress.
