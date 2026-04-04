{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {
      "$mod" = "SUPER";
      monitor = ",preferred,auto,1";

      env = [
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
        "NIXOS_OZONE_WL,1"
      ];

      exec-once = [
        "bash -lc 'command -v qs >/dev/null 2>&1 && qs -c ii || true'"
        "hyprpaper"
        "hypridle"
        "dbus-update-activation-environment --all"
        "hyprctl setcursor Bibata-Modern-Classic 24"
      ];

      input = {
        kb_layout = "us";
        kb_variant = "altgr-intl";
        kb_options = "caps:swapescape";
        numlock_by_default = true;
        repeat_delay = 250;
        repeat_rate = 35;
        follow_mouse = 1;
        off_window_axis_events = 2;
        touchpad.natural_scroll = true;
        touchpad.disable_while_typing = true;
        touchpad.clickfinger_behavior = true;
        touchpad.scroll_factor = 0.7;
      };

      gesture = [
        "3, swipe, move,"
        "3, pinch, float"
        "4, horizontal, workspace"
      ];

      gestures = {
        workspace_swipe_distance = 700;
        workspace_swipe_cancel_ratio = 0.2;
        workspace_swipe_min_speed_to_force = 5;
        workspace_swipe_direction_lock = true;
        workspace_swipe_direction_lock_threshold = 10;
        workspace_swipe_create_new = true;
      };

      general = {
        gaps_in = 4;
        gaps_out = 5;
        gaps_workspaces = 30;
        border_size = 1;
        layout = "dwindle";
        "col.active_border" = "rgba(0DB7D455)";
        "col.inactive_border" = "rgba(31313600)";
        resize_on_border = true;
        no_focus_fallback = true;
      };

      dwindle = {
        preserve_split = true;
        smart_split = false;
        smart_resizing = false;
      };

      decoration = {
        rounding = 18;
        rounding_power = 2.4;
        blur = {
          enabled = true;
          xray = true;
          size = 10;
          passes = 3;
          noise = 0.05;
          contrast = 0.89;
          vibrancy = 0.5;
          popups = false;
        };
        shadow = {
          enabled = true;
          ignore_window = true;
          range = 50;
          offset = "0 4";
          render_power = 10;
          color = "rgba(00000027)";
        };
        dim_inactive = true;
        dim_strength = 0.05;
      };

      animations = {
        enabled = true;
        bezier = [
          "emphasizedDecel, 0.05, 0.7, 0.1, 1"
          "menu_decel, 0.1, 1, 0, 1"
          "menu_accel, 0.52, 0.03, 0.72, 0.08"
        ];
        animation = [
          "windowsIn, 1, 3, emphasizedDecel, popin 80%"
          "windowsOut, 1, 2, emphasizedDecel, popin 90%"
          "windowsMove, 1, 3, emphasizedDecel, slide"
          "fadeIn, 1, 3, emphasizedDecel"
          "fadeOut, 1, 2, emphasizedDecel"
          "workspaces, 1, 7, menu_decel, slide"
        ];
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        vrr = 1;
        allow_session_lock_restore = true;
      };

      cursor = {
        no_hardware_cursors = true;
      };

      bind = [
        "$mod, Return, exec, kitty"
        "$mod, Q, killactive"
        "$mod, F, fullscreen, 1"
        "$mod, R, exec, wofi --show drun"
        "$mod, V, togglefloating"
        "$mod SHIFT, A, killactive"
        "$mod SHIFT, O, exec, reboot"
        "$mod SHIFT, Return, exec, fenos-lock"
        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"
        "$mod, S, togglespecialworkspace"
        "$mod, mouse_up, workspace, +1"
        "$mod, mouse_down, workspace, -1"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
