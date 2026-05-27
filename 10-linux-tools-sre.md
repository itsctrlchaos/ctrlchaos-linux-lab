# 10 Linux Tools I Actually Use Every Day as an SRE

This file contains the tools shown in the video, how to install them on Ubuntu/WSL, and quick demo examples.

> Note: Some package names and command names are different on Ubuntu. For example, `ripgrep` runs as `rg`, and `bat` may run as `batcat`.

---

## 1. fzf

`fzf` is a fuzzy finder that lets you quickly search command history, files, and terminal output.

### Install

```bash
sudo apt update
sudo apt install fzf -y
```

### Verify

```bash
fzf --version
```

### Demo

```bash
history | fzf
```

Or press:

```text
CTRL + R
```

---

## 2. ripgrep

`ripgrep` is a fast search tool and a modern replacement for many `grep` workflows.

### Install

```bash
sudo apt install ripgrep -y
```

### Verify

```bash
rg --version
```

### Demo

```bash
rg "error" .
rg "nginx" /etc
```

---

## 3. jq

`jq` helps you parse, filter, and format JSON from APIs, Kubernetes output, logs, and config files.

### Install

```bash
sudo apt install jq -y
```

### Verify

```bash
jq --version
```

### Demo JSON File

```bash
cat > k8s-demo-pod.json << 'JSON'
{
  "items": [
    {
      "metadata": {
        "name": "nginx-pod",
        "namespace": "production"
      },
      "status": {
        "phase": "Running"
      }
    },
    {
      "metadata": {
        "name": "redis-pod",
        "namespace": "production"
      },
      "status": {
        "phase": "Pending"
      }
    },
    {
      "metadata": {
        "name": "api-server",
        "namespace": "staging"
      },
      "status": {
        "phase": "Running"
      }
    }
  ]
}
JSON
```

### Demo

```bash
jq '.' k8s-demo-pod.json
jq '.items[].metadata.name' k8s-demo-pod.json
jq '.items[] | select(.status.phase=="Running")' k8s-demo-pod.json
```

---

## 4. zoxide

`zoxide` is a smarter version of `cd`. It remembers directories you visit and lets you jump to them quickly.

### Install

```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```

### Enable for Bash

```bash
echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
source ~/.bashrc
```

### Enable for Zsh

```bash
echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
source ~/.zshrc
```

### Verify

```bash
zoxide --version
type z
```

### Demo Setup

```bash
mkdir -p ~/projects/kubernetes-production
mkdir -p ~/projects/terraform-infra
mkdir -p ~/projects/python-api

zoxide add ~/projects/kubernetes-production
zoxide add ~/projects/terraform-infra
zoxide add ~/projects/python-api
```

### Demo

```bash
z kub
z terra
z python
```

---

## 5. bat

`bat` is a modern replacement for `cat` with syntax highlighting, line numbers, and better formatting.

### Install

```bash
sudo apt install bat -y
```

### Verify on Ubuntu

Ubuntu often installs the command as `batcat`:

```bash
batcat --version
```

### Optional Alias

```bash
echo 'alias bat=batcat' >> ~/.bashrc
source ~/.bashrc
```

### Demo

```bash
cat k8s-demo-pod.json
batcat k8s-demo-pod.json
```

If you added the alias:

```bash
bat k8s-demo-pod.json
```

---

## 6. btop

`btop` gives you a clean real-time view of CPU, memory, disks, processes, and network usage.

### Install

```bash
sudo apt install btop -y
```

### Demo

```bash
btop
```

---

## 7. bandwhich

`bandwhich` shows which processes are using network bandwidth in real time.

### Install Rust/Cargo if needed

```bash
sudo apt install cargo -y
```

### Install bandwhich

```bash
cargo install bandwhich
```

### Demo

```bash
sudo ~/.cargo/bin/bandwhich
```

Optional, if you want to run it without the full path:

```bash
echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
sudo bandwhich
```

---

## 8. lazygit

`lazygit` gives you a clean terminal UI for common Git operations like commits, branches, diffs, and history.

### Install

```bash
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

curl -Lo lazygit.tar.gz \
"https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"

tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
```

### Verify

```bash
lazygit --version
```

### Demo

```bash
git init demo-repo
cd demo-repo
printf '# Demo Repo\n' > README.md
git add README.md
lazygit
```

---

## 9. tldr

`tldr` gives short practical examples for commands without reading a full man page.

### Install

```bash
sudo apt install tldr -y
```

### Update Pages

```bash
tldr --update
```

Depending on your installed client, this may also be:

```bash
tldr update
```

### Demo

```bash
tldr tar
tldr find
tldr curl
```

---

## 10. duf

`duf` is a modern alternative to `df -h`. It shows disk usage in a cleaner and easier-to-read format.

### Try apt First

```bash
sudo apt install duf -y
```

### If apt Cannot Find It

```bash
wget https://github.com/muesli/duf/releases/latest/download/duf_0.8.1_linux_amd64.deb
sudo dpkg -i duf_0.8.1_linux_amd64.deb
```

### Demo

```bash
df -h
duf
```

---

## Quick Install Summary

```bash
sudo apt update
sudo apt install fzf ripgrep jq bat btop tldr cargo -y
```

Then install the tools that usually need extra steps:

```bash
# zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
echo 'eval "$(zoxide init bash)"' >> ~/.bashrc
source ~/.bashrc

# bandwhich
cargo install bandwhich

# lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# duf, if not available from apt
wget https://github.com/muesli/duf/releases/latest/download/duf_0.8.1_linux_amd64.deb
sudo dpkg -i duf_0.8.1_linux_amd64.deb
```

---
