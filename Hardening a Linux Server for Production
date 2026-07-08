# Hardening a Linux Server for Production

This guide contains all the commands demonstrated in the lesson **Hardening a Linux Server for Production**. These commands help you perform a quick security assessment of a Linux server before it goes into production.

> **Note:** These commands are intended for auditing and verification. Most of them do **not** modify your system.

---

## 1. Update the System

Install the latest security patches and package updates.

```bash
sudo dnf update -y
```

---

## 2. Check Listening Ports

View all listening TCP and UDP ports along with the processes using them.

```bash
sudo ss -lntup
```

---

## 3. Review Running Services

List all currently running system services.

```bash
systemctl list-units --type=service --state=running
```

---

## 4. Verify Firewall Status

Check whether Firewalld is running.

```bash
sudo firewall-cmd --state
```

Display the active firewall configuration.

```bash
sudo firewall-cmd --list-all
```

---

## 5. Review SSH Configuration

Check whether root login is allowed.

```bash
sudo grep "^PermitRootLogin" /etc/ssh/sshd_config
```

Check whether password authentication is enabled.

```bash
sudo grep "^PasswordAuthentication" /etc/ssh/sshd_config
```

If the settings are managed through included configuration files, search those as well.

```bash
sudo grep -E "PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config.d/*
```

---

## 6. Review Enabled Services

List services that automatically start during boot.

```bash
systemctl list-unit-files --state=enabled
```

---

## 7. Check Failed Login Attempts

Display recent failed login attempts.

```bash
sudo lastb
```

---

## 8. Verify SELinux Status

Quickly check the current SELinux mode.

```bash
getenforce
```

Display detailed SELinux information.

```bash
sestatus
```

---

## 9. Verify Fail2ban

Check whether Fail2ban is running and protecting your server.

```bash
sudo fail2ban-client status
```

---

## 10. Audit the System with Lynis

Run a complete security audit and review the security score, warnings, and recommendations.

```bash
sudo lynis audit system
```

---

## Summary

This checklist helps you quickly review a Linux server's security posture by checking:

- System updates
- Open ports
- Running services
- Firewall configuration
- SSH security settings
- Enabled services
- Failed login attempts
- SELinux status
- Fail2ban protection
- Overall security posture with Lynis
