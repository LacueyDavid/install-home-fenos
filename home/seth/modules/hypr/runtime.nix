{ pkgs, ... }:
let
  hyprctlBin = "${pkgs.hyprland}/bin/hyprctl";
  pgrepBin = "${pkgs.procps}/bin/pgrep";
  hyprlockBin = "${pkgs.hyprlock}/bin/hyprlock";
  nmcliBin = "${pkgs.networkmanager}/bin/nmcli";

  lockCommand = pkgs.writeShellScriptBin "fenos-lock" ''
    set -eu

    # If quickshell is running, ask it to lock first.
    if ${pgrepBin} -x qs >/dev/null 2>&1 || ${pgrepBin} -x quickshell >/dev/null 2>&1; then
      ${hyprctlBin} dispatch global quickshell:lock >/dev/null 2>&1 || true
    fi

    # Fallback lock screen if quickshell lock is not available.
    if ! ${pgrepBin} -x hyprlock >/dev/null 2>&1; then
      exec ${hyprlockBin}
    fi
  '';

  lockStatusScript = pkgs.writeShellScript "fenos-hyprlock-status" ''
    set -eu

    state="unknown"
    if ${nmcliBin} -t -f STATE general >/dev/null 2>&1; then
      state="$(${nmcliBin} -t -f STATE general | head -n1)"
    fi

    printf 'network: %s\n' "$state"
  '';
in
{
  home.packages = [ lockCommand ];

  xdg.configFile."hypr/hypridle.conf".text = ''
    $lock_cmd = fenos-lock
    $suspend_cmd = systemctl suspend || loginctl suspend

    general {
      lock_cmd = $lock_cmd
      before_sleep_cmd = loginctl lock-session
      inhibit_sleep = 3
    }

    listener {
      timeout = 300
      on-timeout = loginctl lock-session
    }

    listener {
      timeout = 600
      on-timeout = ${hyprctlBin} dispatch dpms off
      on-resume = ${hyprctlBin} dispatch dpms on
    }

    listener {
      timeout = 900
      on-timeout = $suspend_cmd
    }
  '';

  xdg.configFile."hypr/hyprlock.conf".text = ''
    background {
      color = rgba(181818FF)
    }

    input-field {
      monitor =
      size = 260, 52
      outline_thickness = 2
      dots_size = 0.12
      dots_spacing = 0.26
      fade_on_empty = true
      font_color = rgba(e7e0e8FF)
      inner_color = rgba(2a2730CC)
      outer_color = rgba(8f8a9aCC)

      position = 0, 20
      halign = center
      valign = center
    }

    label {
      monitor =
      text = $TIME
      color = rgba(e7e0e8FF)
      font_size = 62
      position = 0, 290
      halign = center
      valign = center
    }

    label {
      monitor =
      text = cmd[update:5000] date +"%A, %d %B"
      color = rgba(e7e0e8FF)
      font_size = 16
      position = 0, 235
      halign = center
      valign = center
    }

    label {
      monitor =
      text = $USER
      color = rgba(e7e0e8FF)
      font_size = 18
      position = 0, 58
      halign = center
      valign = bottom
    }

    label {
      monitor =
      text = cmd[update:5000] ${lockStatusScript}
      color = rgba(e7e0e8FF)
      font_size = 13
      position = 25, -25
      halign = left
      valign = top
    }
  '';
}
