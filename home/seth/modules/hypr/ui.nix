{ config, pkgs, ... }:
let
  iiConfig = pkgs.writeText "illogical-impulse-config.json" (
    builtins.replaceStrings
      [
        "/home/seth/pictures/wp.png"
        "/home/seth/Videos"
      ]
      [
        "${config.home.homeDirectory}/pictures/wp.png"
        "${config.home.homeDirectory}/Videos"
      ]
      (builtins.readFile ./illogical-impulse-config.json)
  );
in {
  programs.waybar = {
    enable = true;
    systemd.enable = false;
    settings = [
      {
        layer = "top";
        position = "top";
        height = 38;
        spacing = 8;
        margin-top = 6;
        margin-left = 8;
        margin-right = 8;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "cpu" "memory" "temperature" "network" "pulseaudio" "tray" ];

        "hyprland/window" = {
          format = "{title}";
          separate-outputs = true;
          max-length = 90;
        };

        "hyprland/workspaces" = {
          sort-by-number = true;
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          format = "{name}";
          active-only = false;
          all-outputs = true;
        };

        cpu = {
          interval = 4;
          format = "  {usage}%";
        };

        memory = {
          interval = 4;
          format = "  {used:0.1f}G";
        };

        temperature = {
          interval = 8;
          format = "  {temperatureC}°C";
          critical-threshold = 85;
          format-critical = "  {temperatureC}°C";
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀  wired";
          format-disconnected = "󰖪  down";
          tooltip-format = "{ifname} {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "  {volume}%";
          format-muted = "  mute";
          on-click = "pavucontrol";
        };

        clock = {
          interval = 5;
          format = "{:%H:%M · %a %d/%m}";
          tooltip-format = "{:%A %d %B %Y}";
        };

        tray = {
          spacing = 10;
        };
      }
    ];

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
        font-size: 12px;
        min-height: 0;
        border: none;
      }

      window#waybar {
        background: transparent;
        color: #e6e6e6;
      }

      #window,
      #workspaces,
      #cpu,
      #memory,
      #temperature,
      #network,
      #pulseaudio,
      #clock,
      #tray {
        background: rgba(12, 15, 22, 0.9);
        border: 1px solid rgba(138, 180, 248, 0.23);
        border-radius: 999px;
        padding: 0 11px;
        margin: 0 2px;
      }

      #window {
        padding-left: 14px;
        padding-right: 14px;
      }

      #workspaces button {
        color: #9fa6b2;
        background: transparent;
        border-radius: 999px;
        padding: 0 8px;
        margin: 4px 2px;
      }

      #workspaces button.active {
        color: #e9f2ff;
        background: rgba(57, 110, 255, 0.35);
      }

      #workspaces button:hover {
        color: #f5f7ff;
        background: rgba(57, 110, 255, 0.2);
      }

      #tray {
        padding-right: 10px;
      }
    '';
  };

  xdg.configFile."quickshell".source = ./live/quickshell;
  xdg.configFile."illogical-impulse/config.json".source = iiConfig;

  programs.wofi = {
    enable = true;
    settings = {
      allow_markup = true;
      show = "drun";
      prompt = "run>";
      width = 820;
      height = 520;
      insensitive = true;
      hide_scroll = true;
      columns = 1;
      lines = 11;
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
        font-size: 14px;
      }

      window {
        background: rgba(10, 14, 22, 0.95);
        border: 2px solid rgba(57, 110, 255, 0.42);
        border-radius: 18px;
      }

      #input {
        margin: 12px;
        padding: 12px;
        border-radius: 12px;
        border: 1px solid rgba(150, 185, 255, 0.33);
        background: rgba(16, 22, 36, 0.95);
        color: #f5f7ff;
      }

      #entry {
        margin: 0 12px 8px 12px;
        padding: 10px;
        border-radius: 12px;
      }

      #entry:selected {
        background: rgba(57, 110, 255, 0.3);
      }

      #text {
        color: #e6e6e6;
      }
    '';
  };

  services.mako = {
    enable = true;
    settings = {
      border-radius = 8;
      default-timeout = 5000;
    };
  };

  home.packages = with pkgs; [
    bc
    brightnessctl
    cliphist
    curl
    easyeffects
    fuzzel
    grim
    hypridle
    hyprlock
    hyprpicker
    hyprpaper
    hyprshot
    pavucontrol
    playerctl
    quickshell
    slurp
    tesseract
    waybar
    wl-clipboard
    wl-clip-persist
    wlogout
    wofi
    wtype
  ];
}
