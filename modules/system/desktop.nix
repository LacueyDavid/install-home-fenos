{ pkgs, ... }:
let
  # Wrap `start-hyprland` in a D-Bus session. Otherwise start-hyprland exec's
  # itself into `dbus-run-session Hyprland`, losing its place in the process
  # tree and triggering Hyprland's "not started with start-hyprland" warning.
  #
  # Source home-manager session vars BEFORE launching Hyprland so that
  # QML2_IMPORT_PATH / QT_PLUGIN_PATH are populated. Without this, quickshell
  # exec-once at login runs before the shell init has sourced those vars and
  # crashes on missing `Qt5Compat.GraphicalEffects`.
  sessionLauncher = pkgs.writeShellScript "fenos-session-launcher" ''
    set -e
    hmVars=/etc/profiles/per-user/''${USER:-seth}/etc/profile.d/hm-session-vars.sh
    if [ -f "$hmVars" ]; then set +u; . "$hmVars"; set -u; fi
    exec ${pkgs.dbus}/bin/dbus-run-session ${pkgs.hyprland}/bin/start-hyprland
  '';
in
{
  services.xserver.enable = false;

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --cmd ${sessionLauncher}";
      user = "greeter";
    };
  };

  # Don't restart greetd on rebuild: keeps the running session stable.
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

  services.journald.extraConfig = ''
    SystemMaxUse=500M
    RuntimeMaxUse=200M
  '';
}
