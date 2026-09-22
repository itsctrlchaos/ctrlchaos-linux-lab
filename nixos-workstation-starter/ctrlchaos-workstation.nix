{ config, lib, pkgs, ... }:

let
  cfg = config.ctrlchaos.workstation;
in
{
  options.ctrlchaos.workstation = {
    enable = lib.mkEnableOption "the CTRL+CHAOS practical NixOS workstation";

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/Los_Angeles";
      description = "System time zone, such as America/Los_Angeles or Europe/London.";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "Default system locale.";
    };

    userName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "abe";
      description = "Existing local user to add to the Docker group when Docker is enabled.";
    };

    includeDesktopApps = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install useful graphical desktop applications.";
    };

    includeDevOpsTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install Kubernetes, cloud, automation, and infrastructure tools.";
    };

    enableDocker = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Docker and automatic cleanup of unused Docker data.";
    };

    enableFlatpak = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Flatpak support. Applications are not installed automatically.";
    };

    enablePrinting = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable printing support through CUPS.";
    };

    enableBluetooth = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Bluetooth support and power it on at boot.";
    };

    enableSSH = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable the OpenSSH server with password login disabled.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Basic regional settings
    time.timeZone = cfg.timeZone;
    i18n.defaultLocale = cfg.locale;

    # Nix quality-of-life settings
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.optimise.automatic = true;
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # Some common developer tools require non-free licenses.
    nixpkgs.config.allowUnfree = true;

    # Safe workstation defaults
    networking.networkmanager.enable = true;
    networking.firewall.enable = true;
    boot.tmp.cleanOnBoot = true;
    services.fstrim.enable = true;
    services.fwupd.enable = true;

    services.journald.extraConfig = ''
      SystemMaxUse=1G
      MaxRetentionSec=7day
    '';

    # Shell and development convenience
    programs.bash.completion.enable = true;
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Hardware and desktop services
    services.printing.enable = cfg.enablePrinting;
    services.flatpak.enable = cfg.enableFlatpak;
    hardware.bluetooth = lib.mkIf cfg.enableBluetooth {
      enable = true;
      powerOnBoot = true;
    };

    # Remote access is off by default.
    services.openssh = lib.mkIf cfg.enableSSH {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Docker is optional because it runs a privileged system service.
    virtualisation.docker = lib.mkIf cfg.enableDocker {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    users.users = lib.optionalAttrs (cfg.enableDocker && cfg.userName != null) {
      ${cfg.userName}.extraGroups = [ "docker" ];
    };

    environment.systemPackages =
      (with pkgs; [
        # Everyday command-line tools
        git
        gh
        curl
        wget
        jq
        yq-go
        ripgrep
        fd
        fzf
        bat
        eza
        tree
        file
        which
        nano
        vim
        neovim
        tmux
        rsync
        unzip
        zip
        p7zip
        gnupg
        age
        sops
        openssl

        # Monitoring and troubleshooting
        htop
        btop
        fastfetch
        lsof
        strace
        sysstat
        lm_sensors
        smartmontools
        pciutils
        usbutils

        # Network troubleshooting
        dnsutils
        inetutils
        traceroute
        mtr
        iperf3
        nmap
        tcpdump
        whois

        # General development
        gnumake
        gcc
        python3
        nodejs
        go
        rustup
        lazygit
        shellcheck
        shfmt

        # Nix development
        nil
        nixfmt-rfc-style
        nix-tree
      ])
      ++ lib.optionals cfg.includeDesktopApps (with pkgs; [
        firefox
        vscodium
        vlc
        libreoffice
        gimp
      ])
      ++ lib.optionals cfg.includeDevOpsTools (with pkgs; [
        kubectl
        kubernetes-helm
        k9s
        kustomize
        opentofu
        ansible
        awscli2
      ])
      ++ lib.optionals cfg.enableDocker (with pkgs; [
        docker-compose
      ]);

    fonts.packages = with pkgs; [
      dejavu_fonts
      liberation_ttf
      noto-fonts
      noto-fonts-emoji
    ];
  };
}
