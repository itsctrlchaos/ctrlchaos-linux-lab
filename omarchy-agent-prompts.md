# Omarchy AI Agent Lab

### Describe the goal. Inspect the changes. Verify the result.

A practical prompt collection from **CTRL+CHAOS** for testing an AI agent inside an Omarchy Linux VM.

These examples were written for Codex running inside Omarchy. They are requests for an agent to inspect and adapt to your machine, not shell commands or guaranteed results. The three main challenges follow the video: desktop customization, a specific security fix, and service troubleshooting. Eight bonus prompts explore other useful OS tasks.

## Contents

- [How to use this lab](#how-to-use-this-lab)
- [Demo 1: Customize the desktop](#demo-1-customize-the-desktop)
- [Demo 2: Fix an exposed test service](#demo-2-fix-an-exposed-test-service)
- [Demo 3: Diagnose a broken service](#demo-3-diagnose-a-broken-service)
- [Bonus prompts](#bonus-prompts)
- [Record your results](#record-your-results)

## How to use this lab

1. Start with a test VM and take a snapshot before the main challenges.
2. Copy one fenced prompt into your agent, not into a regular shell.
3. Replace every `<PLACEHOLDER>` before submitting. Prompts without placeholders are ready to paste.
4. Review changes and run the checks below each prompt. A successful agent response is not verification by itself.
5. Record follow-up prompts and manual fixes as part of the result.

The security and broken-service challenges need the prepared conditions described below. They do not assume a fresh Omarchy installation is insecure or broken. For the troubleshooting challenge, prepare the fault separately and start a new agent conversation that has not seen the setup.

-----

## Demo 1: Customize the desktop

**Goal:** Make visible, focused changes while preserving the existing setup.

**Before you start:** Capture a screenshot with two windows open so the border and gap changes are easy to compare.

### Prompt 1A: Appearance

```text
Customize my current Omarchy desktop with these changes:

1. Give windows slightly rounded corners.
2. Add a clear blue border around the focused window.
3. Increase the gaps between windows slightly.

First, inspect my existing configuration and explain which files you need to change. Preserve my current theme, keybindings, and unrelated settings. Use my user configuration rather than modifying Omarchy's managed defaults where possible.

Before editing, create timestamped backups of every file you will change. Record any new files separately so they can be removed during rollback.

Apply the changes and use the available configuration checks to catch errors. Reload the relevant configuration without logging me out or restarting the VM.

Check for errors afterward. Tell me which changes you verified and which ones I need to check visually. Do not claim to have seen the desktop unless you actually have visual access.

When finished, summarize exactly what changed and provide the exact commands to restore my original configuration and reload it.
```

**Verify:** Switch focus between windows, inspect the corners and gaps, and check that your existing shortcuts and theme still work. Compare the configuration diff with the requested changes.

### Prompt 1B: CPU and memory display

Submit this as a separate follow-up after checking the appearance changes.

```text
Add clearly labeled CPU and memory usage indicators to my existing Omarchy desktop bar.

Inspect the current bar implementation and configuration first. Reuse its built-in modules if available. Preserve all existing modules, their behavior, and the rest of my desktop configuration. Do not install a replacement bar.

Show CPU usage as a percentage and memory usage in a compact, readable format. Explain exactly what each value measures, including how memory usage is calculated. Use a reasonable refresh interval of about two seconds if supported.

Create timestamped backups before editing and record any new files. Validate the configuration and reload only what is necessary, without logging me out.

Check that the indicators update and that the bar reports no new errors. If you cannot check the visual result, say so and tell me what to inspect. Provide a short verification procedure using an available system monitor. Do not start a stress test automatically.

Finish with the changed files, the meaning of the displayed values, and exact rollback commands.
```

**Verify:** Compare several updates with a system monitor. Briefly run a controlled workload and check that CPU usage responds. Different sampling intervals and memory definitions can produce different readings; compare like-for-like metrics rather than expecting identical numbers at every instant.

-----

## Demo 2: Fix an exposed test service

**Goal:** Keep a temporary web service working inside the VM while preventing access from another machine.

**Before you start:** Prepare a temporary web service on port 8000 serving only harmless test content. Confirm that the host machine can reach it and record the working address. Use a lab network path that reaches the VM directly; a forwarding proxy can change what source address the guest sees. If access does not work before the test, you cannot use a failed connection afterward as proof of the fix.

### Prompt

```text
Inspect the temporary web service on port 8000. It should be accessible inside this VM, but not from other machines.

Identify the process, how it is launched, its listening addresses, and the relevant network or firewall configuration. Explain what currently makes it reachable and propose the smallest appropriate fix. Ask before applying the change.

Preserve unrelated services, existing firewall rules, and my current remote access. Do not stop or disable the web service as the solution. Account for IPv4 and IPv6 if the service uses them.

Before making approved changes, create timestamped backups of any configuration files you will edit and record the original state needed for rollback.

After applying the approved fix, confirm that the service is still running and that a local HTTP request succeeds. Check its listening state and relevant rules. Explain whether the fix survives a service restart and verify that behavior if the service is managed.

Give me the exact external test to repeat from my host machine. Do not claim external access is blocked unless that test has actually been performed from outside the VM.

Finish with the diagnosis, changes, evidence, any checks still pending, and exact undo commands.
```

**Verify:** Repeat the same request from the host that worked before. It should now fail, while a request inside the VM should still succeed. Confirm that the process is running. This demonstrates one access requirement, not a complete security audit.

-----

## Demo 3: Diagnose a broken service

**Goal:** Find the cause from evidence and repair it with a minimal change.

**Before you start:** Use a dedicated, nonessential demo service. Confirm it works, then introduce an incorrect executable path in its service configuration and confirm startup fails. Do not use a desktop, networking, login, or other essential service. Prepare the fault outside the agent conversation used for diagnosis.

**Replace:** `<SERVICE_NAME>` with your demo service's actual unit name. The agent should inspect whether it is a user or system service.

### Prompt

```text
This demo service fails to start: <SERVICE_NAME>.

Diagnose the cause using its status, logs, and configuration. First determine whether it is a user service or a system service. Explain the evidence before making changes, and distinguish confirmed findings from guesses.

Apply the smallest necessary fix. Do not recreate or replace the service, reinstall unrelated packages, or make broad permission changes.

Create a timestamped backup of every configuration file before editing. Record the original state and any new files needed for rollback.

After the fix, reload the service manager configuration if needed, start the service, and check for new errors. Verify that the application actually performs its intended function, rather than relying only on an active status. Restart it once and repeat the functional check.

Finish with the root cause, the evidence that supports it, the exact configuration change, verification results, and commands to restore the pre-fix state. Clearly label rollback as restoring the original broken state.
```

**Verify:** Compare the diagnosis with the fault you introduced. Inspect the diff, test the application's function, and restart it once. Track any hints you had to give the agent.

-----

## Bonus prompts

These are complementary examples, not extra steps required for the three main demos.

| Example | Useful for | Mode |
| --- | --- | --- |
| 1. Disk-space detective | Finding what consumes storage | Read-only |
| 2. Slow-start investigation | Explaining boot or login delays | Read-only |
| 3. Network and DNS diagnosis | Finding why one site fails | Read-only |
| 4. Resource-usage snapshot | Investigating an unexpectedly slow system | Read-only |
| 5. Desktop backup and restore | Recovering personal configuration | Creates a local backup |
| 6. Application shortcut | Launching a favorite app quickly | Changes user configuration |
| 7. Downloads organizer | Sorting files without losing track of them | Preview, then approved moves |
| 8. Local development launcher | Starting a project with one command | Creates a user script |

### 1. Disk-space detective

```text
Investigate what is using storage on this machine. This is a read-only task: do not delete, truncate, move, or clean anything.

Start with filesystem capacity and identify which filesystem is running low. Inspect relevant directories without crossing into unrelated mounts or network filesystems. Use allocated disk usage where possible and explain any important difference from apparent file sizes.

Identify the largest useful categories, such as downloads, package caches, logs, virtual machine images, and application data. Do not print private file contents or secrets.

Return a ranked table with path, approximate allocated size, likely purpose, and whether cleanup needs further investigation. Separate low-risk cleanup candidates from personal files and application state. Account for hard links, snapshots, or deleted-but-open files if the evidence suggests they matter.

Suggest specific cleanup actions and estimated recoverable space without double-counting. Wait for my approval before performing any cleanup.
```

**Verify:** Inspect the largest reported paths and compare the totals with filesystem usage. No space should have been reclaimed by this inspection alone.

### 2. Slow-start investigation

```text
Investigate why this machine takes a long time to boot or reach a usable desktop. Keep the investigation read-only.

Inspect the available boot timing information, dependency ordering, failed services, and relevant logs from the current boot. Distinguish system boot time from user-session startup time. If this is a VM, identify evidence of guest or host-related delays without assuming the host is the cause.

Do not rank a service as the cause solely because it has a long duration; check whether it actually delays the critical startup path. Do not disable services or change startup settings.

Give me the top three evidence-backed findings, explain what remains uncertain, and propose one focused change to test first. Include the before-and-after measurement procedure and a rollback plan, but wait for approval before changing anything.
```

**Verify:** Check that each conclusion cites an observed delay or dependency. A list of long-running startup units alone is not a diagnosis.

### 3. Network and DNS diagnosis

Replace `<URL>` with a public URL that should be reachable. Do not include credentials or tokens.

```text
I cannot reliably reach <URL> from this machine. Diagnose the problem without changing any network settings.

Inspect the network link, addresses, routing, configured DNS resolver, and relevant proxy settings. Then test name resolution, connection establishment, TLS, and an HTTP request as separate steps using available tools.

Distinguish DNS failure, routing failure, a refused connection, a timeout, a certificate problem, and an application-level HTTP error. If IPv4 and IPv6 behave differently, show the evidence. Do not treat a failed ping as proof that the website is down.

Do not disable the firewall, replace DNS servers, bypass TLS verification, or restart network services. Redact credentials and tokens in any output.

Return a short diagnosis with the commands used, observations, likely cause, and the smallest proposed next step. State clearly if the available evidence is inconclusive.
```

**Verify:** Repeat the failing layer's test and a known-good comparison. Make sure a proposed fix targets the observed failure.

### 4. Resource-usage snapshot

```text
This machine feels slow. Collect a short, read-only resource-usage snapshot for about 30 seconds using tools already installed.

Inspect CPU activity, runnable or blocked tasks, memory availability, swap activity, disk I/O, and pressure indicators where available. Identify relevant processes without exposing sensitive command-line arguments.

Do not install packages, start benchmarks, kill processes, clear caches, or change system settings. Distinguish CPU saturation, memory pressure, and storage delays using multiple observations rather than one percentage.

Summarize the strongest evidence, the limits of this short sample, and the next measurement most likely to narrow the cause. If the slowdown is not occurring during the sample, say so instead of inventing a bottleneck.
```

**Verify:** Match the observation period to when the slowdown actually occurs. Look for supporting evidence across more than one metric.

### 5. Desktop backup and restore

```text
Create a local backup of the user configuration needed to restore my current Omarchy desktop appearance, bar, terminal preferences, and custom keybindings.

Inspect which configuration files are actually active. Select only relevant user configuration. Exclude credentials, tokens, SSH keys, browser profiles, shell history, caches, and unrelated application data. Do not follow symlinks blindly; explain how linked configuration is handled.

Create the backup in a new timestamped directory under ~/omarchy-desktop-backups with access restricted to my user. Include a manifest of original paths, a checksum list, and a README with exact restore steps. Do not alter the active configuration.

Test that the backup can be read and that its checksums match. If you create an archive, test extraction into a separate temporary directory, never over my live configuration. Explain any omissions and why this is a configuration backup rather than a complete OS backup.

Report the backup location and verification results. Do not upload the backup anywhere.
```

**Verify:** Inspect the manifest and test recovery into a temporary directory. Check that restore instructions first preserve the configuration being replaced.

### 6. Application shortcut

Replace `<APPLICATION>` with an installed app and `<KEY_COMBINATION>` with your preferred shortcut.

```text
Add a keyboard shortcut to launch <APPLICATION> using <KEY_COMBINATION> in my Omarchy desktop.

Inspect the current keybinding configuration, included files, and the installed application's launch command. Check for shortcut conflicts before editing. If the combination is already assigned, explain the conflict and ask me to choose another one rather than replacing it.

Use the appropriate user configuration and preserve all unrelated shortcuts. Back up every file you change with a timestamp and record any new file.

Validate the configuration and reload only what is needed without logging me out. Verify the launch command independently and tell me how to test the actual shortcut from the desktop.

Provide the changed lines and exact restore commands. Do not claim the keyboard shortcut was tested unless you actually exercised it.
```

**Verify:** Press the shortcut, confirm the correct app opens, and try nearby existing shortcuts to check for conflicts.

### 7. Downloads organizer

```text
Help me organize the top level of my ~/Downloads directory into Documents, Images, Videos, Archives, and Other.

Begin with a dry run only. Inspect file names, types, and sizes without opening private document contents. Skip directories, hidden files, symlinks, partial downloads, and files that appear to be actively written.

Show the proposed destinations and a count and total size for each category. Never overwrite a destination file. Detect collisions and propose unique names. Do not delete anything or recursively reorganize existing directories.

Wait for my approval before moving files. After approval, move only the approved set, rechecking for changed files and destination collisions. Record every original and new path in a local manifest with access restricted to my user.

Verify each move and provide a reversal procedure that checks for collisions and changed files before moving anything back. Report skipped files separately.
```

**Verify:** Review the preview first. After approved moves, compare the manifest with the actual files and inspect the reversal procedure.

### 8. Local development launcher

Replace `<PROJECT_DIRECTORY>` with the full path to a local project.

```text
Create a convenient user-level launcher for the project at <PROJECT_DIRECTORY>.

Inspect its README and existing scripts to identify the intended development command. Do not install dependencies, change project source code, or guess missing configuration. If the command or required environment is unclear, explain what is missing before proceeding.

Create a small, clearly named script under ~/.local/bin that enters the project directory and runs the existing development command in the foreground. Quote paths correctly, fail clearly if prerequisites are missing, preserve exit status, and allow Ctrl+C to stop the process cleanly. Do not hard-code secrets.

Check for existing files with the same name. Back up anything you need to modify and do not overwrite unrelated launchers. Prefer local-only network access for a development server; explain any existing externally exposed binding before starting it.

Validate the script, tell me how to run it, and explain whether ~/.local/bin is already on my PATH. Do not edit shell startup files or start a persistent background service without asking.

Provide the created file path, verification results, and exact removal or restore commands.
```

**Verify:** Run the launcher, check the project behaves as expected, stop it with Ctrl+C, and confirm no unintended background process remains.

-----

## Record your results

Use this table for your own run. Blank results are intentional: this collection does not claim these prompts have passed on your configuration.

| Challenge | First attempt | Follow-up prompts | Manual changes | Verified result |
| --- | --- | --- | --- | --- |
| Desktop appearance | | | | |
| CPU and memory display | | | | |
| Test-service access | | | | |
| Broken-service diagnosis | | | | |

For each result, keep the relevant configuration diff, verification output, and rollback instructions. Record the Omarchy version, agent version, and selected model alongside your results so another viewer can understand what you tested.

**The rule of the lab: “Done” is not proof.**

Created for [CTRL+CHAOS](https://www.youtube.com/@itsctrlchaos).
