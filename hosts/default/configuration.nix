{ pkgs, ... }:
let
  fenosSessionLauncher = pkgs.writeShellScript "fenos-session-launcher" ''
    set -euo pipefail

    if ${pkgs.systemd}/bin/systemd-detect-virt -q; then
      # In VMs, keep a compositor fallback but avoid forcing software rendering,
      # which can crash mesa/llvmpipe on some virtio setups.
      exec ${pkgs.bash}/bin/bash -lc 'exec dbus-run-session sh -lc "Hyprland || exec sway"'
    fi

    exec dbus-run-session Hyprland
  '';
in {
  # Ensure stage-1 can see the virtual disk and open the LUKS container
  # before mounting / from /dev/mapper/crypted.
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "ahci"
    "sd_mod"
  ];

  boot.initrd.luks.devices."crypted" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    preLVM = true;
    allowDiscards = true;
  };

  # Keep disk/boot definitions aligned with the bootstrap disko layout.
  fileSystems."/" = {
    device = "/dev/mapper/crypted";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-main-ESP";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  system.stateVersion = "25.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

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
