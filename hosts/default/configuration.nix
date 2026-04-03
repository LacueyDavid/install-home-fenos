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

  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.download-buffer-size = 134217728;
  nixpkgs.config.allowUnfree = true;

  # Keep broad Wi-Fi firmware support on the fully configured installed system.
  hardware.enableRedistributableFirmware = true;

  # Explicitly enable graphics userspace required by Wayland compositors.
  hardware.graphics.enable = true;

  networking.networkmanager.enable = true;

  services.xserver.enable = false;
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${fenosSessionLauncher}";
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

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  security.polkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.users.seth = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    # Keep nmcli available on the final installed system after rebuild.
    networkmanager
    git
    neovim
    wget
    kitty
    waybar
    wofi
    mako
    hyprpaper
    wl-clipboard
    grim
    slurp
  ];
}
