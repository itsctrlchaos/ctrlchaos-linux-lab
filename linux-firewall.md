# Linux Firewalls Explained

### UFW, iptables, and nftables

This repository contains examples used in the **Linux Firewalls Explained** video.

Topics covered:

* UFW
* iptables
* nftables
* Sets
* Maps
* IP Blacklists
* Packet filtering with Netcat

# Requirements

Ubuntu 24.04+

Install nftables:

```bash
sudo apt update
sudo apt install nftables netcat-openbsd
```

# UFW Examples

Check firewall status

```bash
sudo ufw status verbose
```

Set default policies

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

Allow SSH

```bash
sudo ufw allow ssh
```

Allow HTTP and HTTPS

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

Show configured rules

```bash
sudo ufw status numbered
```

Enable UFW

```bash
sudo ufw enable
```

# iptables Examples

List rules

```bash
sudo iptables -L -n -v
```

Add a DROP rule

```bash
sudo iptables -A INPUT -p tcp --dport 8080 -j DROP
```

Display rule numbers

```bash
sudo iptables -L INPUT -n -v --line-numbers
```

Delete rule number 1

```bash
sudo iptables -D INPUT 1
```

# Packet Filtering Demo

Terminal 1

```bash
nc -l 8080
```

Terminal 2

```bash
nc <server-ip> 8080
```

Send message

```text
hello from client
```

Check counters

```bash
sudo iptables -L INPUT -n -v --line-numbers
```

# nftables Examples

## Basic Configuration

firewall-basic.nft

```nft
flush ruleset

table inet filter {

    chain input {

        type filter hook input priority 0;

        policy accept;

    }

}
```

Load

```bash
sudo nft -f firewall-basic.nft
```

Display rules

```bash
sudo nft list ruleset
```

---

## Drop Port 8080

firewall-drop-8080.nft

```nft
flush ruleset

table inet filter {

    chain input {

        type filter hook input priority 0;

        policy accept;

        tcp dport 8080 drop;

    }

}
```

Load

```bash
sudo nft -f firewall-drop-8080.nft
```

---

## Sets

firewall-set.nft

```nft
flush ruleset

table inet filter {

    set allowed_ports {

        type inet_service

        elements = {

            22,
            80,
            443

        }

    }


    chain input {

        type filter hook input priority 0;

        policy accept;


        tcp dport @allowed_ports accept;

    }

}
```

Load

```bash
sudo nft -f firewall-set.nft
```

---

## Blacklist

firewall-blacklist.nft

```nft
flush ruleset

table inet filter {

    set blacklist {

        type ipv4_addr


        elements = {

            203.0.113.10,
            198.51.100.25,
            192.0.2.50,
            45.67.89.123

        }

    }


    chain input {

        type filter hook input priority 0;

        policy accept;


        ip saddr @blacklist drop;

    }

}
```

Load

```bash
sudo nft -f firewall-blacklist.nft
```

Add IP

```bash
sudo nft add element inet filter blacklist { 8.8.8.8 }
```

Remove IP

```bash
sudo nft delete element inet filter blacklist { 192.0.2.50 }
```

---

## Maps

firewall-map.nft

```nft
flush ruleset

table inet filter {

    map service_policy {

        type inet_service : verdict


        elements = {

            22   : accept,
            80   : accept,
            443  : accept,
            23   : drop,
            8080 : drop

        }

    }


    chain input {

        type filter hook input priority 0;

        policy accept;


        tcp dport vmap @service_policy;

    }

}
```

Load

```bash
sudo nft -f firewall-map.nft
```

# Cleanup

Remove all nftables rules

```bash
sudo nft flush ruleset
```

Disable UFW

```bash
sudo ufw disable
```

# Key Takeaways

* UFW is a frontend.
* iptables is still widely used but mostly maintained for compatibility.
* nftables is the modern Linux firewall framework.
* nftables introduces useful data structures such as sets and maps.
* iptables is command oriented.
* nftables is configuration oriented.

```
```
