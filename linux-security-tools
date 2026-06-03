# 10 Linux Tools Every Cybersecurity Engineer Should Know

This repository contains the demo environment and setup instructions used in the YouTube video:

**10 Linux Tools Every Cybersecurity Engineer Should Know**

The goal is not to build a secure production environment. The goal is to generate realistic output so you can learn how these tools work and follow along with the demonstrations.

---

# Lab Environment

Ubuntu 24.04 LTS

Update packages:

```bash
sudo apt update
sudo apt upgrade -y
```

---

# 1. ss

## Purpose

View listening ports and active network connections.

## Demo Setup

Start a temporary web server:

```bash
python3 -m http.server 8080
```

Verify:

```bash
ss -tulpn
```

Expected result:

You should see port 8080 listening.

---

# 2. lsof

## Purpose

Identify which process owns a port or file.

## Demo Setup

Keep the Python web server running:

```bash
python3 -m http.server 8080
```

Run:

```bash
lsof -i :8080
```

Expected result:

You should see the Python process that owns port 8080.

---

# 3. journalctl

## Purpose

Investigate system and service logs.

## Demo Setup

Generate SSH log entries:

```bash
ssh invalid-user@localhost
```

You can also restart SSH:

```bash
sudo systemctl restart ssh
```

Review logs:

```bash
journalctl -u ssh --since "1 hour ago"
```

Expected result:

Authentication failures and service events.

---

# 4. netcat (nc)

## Purpose

Test connectivity and transfer data between systems.

## Demo Setup

Terminal 1:

```bash
nc -lvnp 4444
```

Terminal 2:

```bash
nc localhost 4444
```

Type:

```text
hello from client
```

Expected result:

Messages appear instantly between both terminals.

---

# 5. ausearch

## Purpose

Search Linux audit logs.

## Install

```bash
sudo apt install auditd -y
```

Enable service:

```bash
sudo systemctl enable auditd
sudo systemctl start auditd
```

Generate activity:

```bash
sudo ls /root
sudo cat /etc/shadow
```

Search audit logs:

```bash
ausearch -m USER_CMD
```

Expected result:

Recorded command activity.

---

# 6. tcpdump

## Purpose

Capture and analyze network traffic.

## Install

```bash
sudo apt install tcpdump -y
```

Terminal 1:

```bash
sudo tcpdump -i any
```

Terminal 2:

```bash
curl https://google.com
```

Expected result:

Network packets displayed in real time.

---

# 7. nmap

## Purpose

Discover open ports and services.

## Install

```bash
sudo apt install nmap -y
```

Start a local service:

```bash
python3 -m http.server 8080
```

Scan localhost:

```bash
nmap localhost
```

Expected result:

Port 8080 should appear as open.

---

# 8. fail2ban

## Purpose

Automatically block brute-force attacks.

## Install

```bash
sudo apt install fail2ban -y
```

Start service:

```bash
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

Check status:

```bash
fail2ban-client status
```

Check SSH jail:

```bash
fail2ban-client status sshd
```

Generate failed logins:

```bash
ssh fakeuser@localhost
```

Repeat multiple times.

Expected result:

Fail2Ban detects suspicious login attempts.

---

# 9. Lynis

## Purpose

Perform Linux security audits.

## Install

```bash
sudo apt install lynis -y
```

Run audit:

```bash
sudo lynis audit system
```

Expected result:

Security score, warnings, and hardening recommendations.

---

# 10. OpenSSL

## Purpose

Inspect SSL/TLS certificates and troubleshoot encrypted connections.

## Verify installation

```bash
openssl version
```

Connect to a website:

```bash
openssl s_client -connect google.com:443
```

Expected result:

Certificate information, TLS details, and connection diagnostics.

---

# Cleanup

Stop temporary web server:

```bash
pkill -f "http.server"
```

Stop netcat listener:

```bash
pkill nc
```

---

# Disclaimer

These examples are intended for educational and lab purposes only.

Always obtain proper authorization before scanning, auditing, or testing systems that you do not own or manage.
