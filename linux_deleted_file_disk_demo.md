# Linux Disk Space Demo: Deleted File Still Using Space

This demo simulates a common Linux troubleshooting scenario:

A large file is deleted, but the filesystem still shows the disk space as used because a running process still has the file open.

---

## 1. Create the Demo Directory

```bash
mkdir -p ~/disk-demo
cd ~/disk-demo
```

## 2. Check Disk Usage Before the Demo

```bash
df -h /
```

Use this as the baseline before creating the large file.

## 3. Create a Large 10 GB Demo File

```bash
dd if=/dev/zero of=big-demo.log bs=1M count=10240 status=progress
sync
```

Quick meaning:

- `dd` creates the file.
- `bs=1M` writes in 1 MB blocks.
- `count=10240` creates about 10 GB.
- `status=progress` shows creation progress.
- `sync` flushes buffered writes to disk.

Verify:

```bash
ls -lh big-demo.log
df -h /
```

## 4. Start a Process That Keeps the File Open

```bash
python3 -c 'import time; f=open("big-demo.log","a"); print("holding file open"); time.sleep(99999)' &
```

This simulates an application that still has the log file open.

The final `&` runs the process in the background.

## 5. Find the Background Process

```bash
jobs -l
```

This shows background jobs started from the current shell, including their PID.

Example:

```text
[1]+ 12237 Running python3 ...
```

## 6. Delete the File

```bash
rm big-demo.log
```

Confirm it is gone:

```bash
ls -lh
```

## 7. Check Disk Usage Again

```bash
df -h /
```

The file is gone from the directory, but the disk space should still be in use.

## 8. Find Deleted Files That Are Still Open

```bash
lsof +L1 | grep big-demo
```

`lsof` means **List Open Files**.

It shows which files are currently open and which processes are using them.

`+L1` helps find files that were deleted from the filesystem but are still open by a running process.

Example:

```text
python3  12237  root  3w  REG  253,0  10737418240  0  50966234  /root/disk-demo/big-demo.log (deleted)
```

The key part is:

```text
(deleted)
```

## 9. Release the Disk Space

Use the PID from `jobs -l` or `lsof`:

```bash
kill <PID>
```

Example:

```bash
kill 12237
```

## 10. Verify That the Space Was Released

```bash
df -h /
```

The filesystem usage should now drop.

---

# Quick Demo Command Sequence

```bash
mkdir -p ~/disk-demo
cd ~/disk-demo

df -h /

dd if=/dev/zero of=big-demo.log bs=1M count=10240 status=progress
sync

ls -lh big-demo.log
df -h /

python3 -c 'import time; f=open("big-demo.log","a"); print("holding file open"); time.sleep(99999)' &

jobs -l

rm big-demo.log

ls -lh
df -h /

lsof +L1 | grep big-demo

kill <PID>

df -h /
```

## Cleanup

```bash
cd ~
rm -rf ~/disk-demo
```

> **Safety:** This demo intentionally creates a large file. Make sure the VM has enough free disk space. Reduce `count=10240` if needed.
