{ pkgs, ... }:
{
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

  networking.networkmanager.enable = true;

  services.xserver.enable = false;
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd Hyprland";
      user = "greeter";
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

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
