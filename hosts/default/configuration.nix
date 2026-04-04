{ pkgs, ... }:
let
  fenosSessionLauncher = pkgs.writeShellScript "fenos-session-launcher" ''
    set -euo pipefail
    exec dbus-run-session Hyprland
  '';
in {
  # Physical profile: no VM-specific virtio tuning here.
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "uas"
    "sr_mod"
    "ahci"
    "sd_mod"
  ];

  boot.initrd.luks.devices."crypted" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    preLVM = true;
    allowDiscards = true;
  };

  # Keep disk/boot definitions aligned with bootstrap disko layout: LUKS + LVM.
  fileSystems."/" = {
    device = "/dev/mapper/crypted--vg-root";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "/dev/mapper/crypted--vg-home";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/mapper/crypted--vg-swap"; }
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-main-ESP";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;

  system.stateVersion = "25.05";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    download-buffer-size = 134217728;
    # Keep a safety margin on small root partitions.
    min-free = 2147483648;
    max-free = 8589934592;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";

  console.useXkbConfig = true;

  # Keep broad Wi-Fi firmware support on the fully configured installed system.
  hardware.enableRedistributableFirmware = true;

  # Explicitly enable graphics userspace required by Wayland compositors.
  hardware.graphics.enable = true;

  networking = {
    networkmanager.enable = true;
    networkmanager.wifi.powersave = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  services.xserver.enable = false;
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd ${fenosSessionLauncher}";
      user = "greeter";
    };
  };

  # Keep the current graphical/tty session stable during `nixos-rebuild switch`.
  # New greetd config is applied on next reboot.
  systemd.services.greetd.restartIfChanged = false;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.sway.enable = true;
  programs.zsh.enable = true;
  programs.nix-ld.enable = true;

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.fwupd.enable = true;

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=200M
  '';

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  users.users.seth = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  services.openssh.enable = true;

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  environment.systemPackages = with pkgs; [
    # Keep a minimal rescue-friendly base at system level.
    networkmanager
    curl
    fd
    htop
    git
    neovim
    ripgrep
    wget
  ];
}
