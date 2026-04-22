{ lib, pkgs, ... }:
let
  shellConfig = ../../dotfiles/hypr/quickshell/ii;
  # Build a directory with both `ii` and `default` entries pointing at our
  # patched config.  This lets us override the upstream whole-directory
  # xdg.configFile."quickshell" entry without creating a subpath conflict:
  # home-manager would follow the store symlink when resolving
  # "quickshell/default" and report it as "outside $HOME".
  quickshellConfig = pkgs.runCommand "quickshell-config" {} ''
    mkdir -p $out
    ln -s ${shellConfig} $out/ii
    ln -s ${shellConfig} $out/default
  '';
in
{
  xdg.configFile."quickshell" = lib.mkForce { source = quickshellConfig; };
}
