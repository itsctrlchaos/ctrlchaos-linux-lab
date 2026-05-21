# 🚀 10 Linux Commands That Make You Look Like a Hacker

The official CTRL CHAOS toolbox.  
Every command, setup, terminal trick, and Linux tool from the videos lives here.

📺 YouTube: @itsctrlchaos

---

# 1. hollywood

Fake Hollywood-style hacker terminal activity.

```bash
sudo apt install hollywood
```

Run:

```bash
hollywood
```

---

# 2. fastfetch

Beautiful modern system information display.

```bash
sudo apt install fastfetch
```

Run:

```bash
fastfetch
```

---

# 3. btop

Modern resource monitor for Linux.

```bash
sudo apt install btop
```

Run:

```bash
btop
```

---

# 4. genact

Fake DevOps/hacker activity generator.

Install Rust first:

```bash
curl https://sh.rustup.rs -sSf | sh
source "$HOME/.cargo/env"
sudo apt install build-essential pkg-config
```

Install genact:

```bash
cargo install genact
```

Run:

```bash
genact
```

---

# 5. bandwhich

Real-time terminal bandwidth monitor.

Install:

```bash
cargo install bandwhich
```

Run:

```bash
sudo ~/.cargo/bin/bandwhich
```

Demo traffic:

```bash
curl -L -o /dev/null https://ash-speed.hetzner.com/100MB.bin
```

---

# 6. glow

Beautiful markdown renderer for terminal.

Install:

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update
sudo apt install glow
```

Run:

```bash
glow README.md
```

---

# 7. ncdu

Powerful interactive disk usage analyzer.

```bash
sudo apt install ncdu
```

Run:

```bash
ncdu ~
```

Full system scan:

```bash
sudo ncdu /
```

---

# 8. cmatrix

Classic Matrix-style terminal effect.

```bash
sudo apt install cmatrix
```

Run:

```bash
cmatrix
```

---

# 9. pipes.sh

Animated pipes inside terminal.

```bash
sudo apt install pipes.sh
```

Run:

```bash
pipes.sh
```

---

# 10. asciiquarium

Animated aquarium in terminal 😄

Install:

```bash
sudo apt install libcurses-perl git cpanminus
git clone https://github.com/cmatsuoka/asciiquarium.git
cd asciiquarium
sudo cpanm Term::Animation
```

Run:

```bash
perl asciiquarium
```

---

# 💻 Terminal Setup Used In The Videos

- Ubuntu 24.04
- WSL2
- ZSH
- Oh My Zsh
- Powerlevel10k
- Windows Terminal

---

# ⚡ CTRL CHAOS

If you enjoyed the video, consider subscribing on YouTube:

📺 @itsctrlchaos
