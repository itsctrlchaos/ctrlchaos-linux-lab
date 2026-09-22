# CTRL+CHAOS NixOS Workstation Starter

A practical NixOS module for turning an existing graphical NixOS installation into a useful daily workstation.

Target release: NixOS 26.05. Package names and options may change in future releases.

It includes:

- Everyday terminal utilities
- Development tools for Python, Node.js, Go, Rust, and shell scripts
- Linux and network troubleshooting tools
- Optional Kubernetes, AWS, Ansible, and OpenTofu tools
- Optional desktop applications
- Automatic Nix garbage collection and store optimization
- Firewall, firmware updates, SSD trimming, printing, and Bluetooth
- Optional Docker, Flatpak, and OpenSSH

## Important

This module does not configure your disks, bootloader, GPU driver, desktop environment, passwords, or hardware. Keep the `hardware-configuration.nix` and `system.stateVersion` created by your own NixOS installation.

Read the file before enabling it. Remove anything you do not want.

## Install

Download the module into your NixOS configuration directory:

```bash
sudo curl -L \
  https://raw.githubusercontent.com/itsctrlchaos/ctrlchaos-linux-lab/main/nixos-workstation-starter/ctrlchaos-workstation.nix \
  -o /etc/nixos/ctrlchaos-workstation.nix
```

Open your main configuration:

```bash
sudo nano /etc/nixos/configuration.nix
```

Add the module to `imports`:

```nix
imports = [
  ./hardware-configuration.nix
  ./ctrlchaos-workstation.nix
];
```

Then add this configuration anywhere inside the main `{ ... }` block:

```nix
ctrlchaos.workstation = {
  enable = true;
  timeZone = "America/Los_Angeles";
  userName = "YOUR-LINUX-USERNAME";

  includeDesktopApps = true;
  includeDevOpsTools = true;

  enableDocker = false;
  enableFlatpak = false;
  enablePrinting = true;
  enableBluetooth = true;
  enableSSH = false;
};
```

Check the configuration without activating it:

```bash
sudo nixos-rebuild test
```

If the test succeeds, activate it:

```bash
sudo nixos-rebuild switch
```

## Smaller beginner setup

To start with fewer packages and services:

```nix
ctrlchaos.workstation = {
  enable = true;
  timeZone = "America/Los_Angeles";
  includeDesktopApps = true;
  includeDevOpsTools = false;
  enablePrinting = false;
  enableBluetooth = false;
};
```

## Docker

Docker is disabled by default. To enable it and allow your normal user to run Docker commands:

```nix
ctrlchaos.workstation.enableDocker = true;
ctrlchaos.workstation.userName = "YOUR-LINUX-USERNAME";
```

Log out and back in after the rebuild so the new group membership takes effect.

## SSH

The SSH server is disabled by default. When enabled, password authentication and root login remain disabled. Add your SSH public key to your normal NixOS user configuration before enabling it.

## Roll back

If you do not like the result:

```bash
sudo nixos-rebuild switch --rollback
```

You can also reboot and choose an older NixOS generation from the boot menu.

## Customize

This is a starting point, not a perfect configuration for every person. Fork the repository and change the package list and options for your own workflow.

Created for the CTRL+CHAOS YouTube community.
