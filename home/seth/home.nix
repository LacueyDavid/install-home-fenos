{ pkgs, ... }:
{
  home.username = "seth";
  home.homeDirectory = "/home/seth";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "seth";
    userEmail = "seth@example.com";
  };

  programs.zsh.enable = true;

  xdg.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      "$mod" = "SUPER";
      monitor = ",preferred,auto,1";

      exec-once = [
        "waybar"
        "mako"
      ];

      input = {
        kb_layout = "fr";
        follow_mouse = 1;
        touchpad.natural_scroll = true;
      };

      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
        "col.active_border" = "rgb(89b4fa)";
        "col.inactive_border" = "rgb(585b70)";
      };

      decoration = {
        rounding = 8;
      };

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive,"
        "$mod, F, fullscreen, 1"
        "$mod, R, exec, wofi --show drun"
        "$mod, V, togglefloating,"
        "$mod, M, exit,"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  home.packages = with pkgs; [
    htop
    ripgrep
    fd
    kitty
    waybar
    wofi
    mako
    wl-clipboard
    grim
    slurp
  ];
}
