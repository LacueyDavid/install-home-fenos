{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  services.mako = {
    enable = true;
    settings = {
      border-radius = 8;
      default-timeout = 5000;
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      allow_markup = true;
      prompt = "run>";
      show = "drun";
      width = 640;
    };
  };

  home.packages = with pkgs; [
    brightnessctl
    cliphist
    grim
    hypridle
    hyprlock
    hyprpicker
    hyprpaper
    playerctl
    slurp
    wl-clipboard
    wl-clip-persist
  ];
}
