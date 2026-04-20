illogical-impulse-dotfiles: { config, pkgs, lib, ... }:
with lib;
let
in
{
  options.illogical-impulse = {
    enable = mkEnableOption "Enable illogical-impulse";
    hyprland = {
      monitor = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ",preferred,auto,1" ];
        description = "Monitor preferences for Hyprland";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.hyprland;
        description = "Hyprland package";
      };
      xdgPortalPackage = lib.mkOption {
        type = lib.types.package;
        default = pkgs.xdg-desktop-portal-hyprland;
        description = "xdg-desktop-portal package for Hyprland";
      };
      ozoneWayland.enable = lib.mkEnableOption "Set NIXOS_OZONE_WL=1";
    };

    dotfiles = {
      kitty.enable = mkEnableOption "Enable illogical-impulse kitty";
      fish.enable = mkEnableOption "Enable illogical-impulse fish";
      starship.enable = mkEnableOption "Enable illogical-impulse starship";
    };
  };

  config = mkMerge [
    (mkIf (config.illogical-impulse.enable) {
      xdg.configFile."Kvantum/Colloid".source = "${illogical-impulse-dotfiles}/.config/Kvantum/Colloid";
      xdg.configFile."matugen".source = "${illogical-impulse-dotfiles}/.config/matugen";
      xdg.configFile."mpv/mpv.conf".source = "${illogical-impulse-dotfiles}/.config/mpv/mpv.conf";
      xdg.configFile."fish/config.fish".source = "${illogical-impulse-dotfiles}/.config/fish/config.fish";

      # Base KDE/Dolphin theme: MaterialAdw color scheme + breeze-dark icons + Kvantum.
      # kde-material-you-colors will overwrite this when a wallpaper is applied.
      home.activation.initKdeglobals = lib.hm.dag.entryAfter ["writeBoundary"] ''
        KDEG="$HOME/.config/kdeglobals"
        # Only write if the file is missing or still uses the old DarkViolet scheme.
        if [ ! -f "$KDEG" ] || grep -q "ColorScheme=DarkViolet" "$KDEG"; then
          cat > "$KDEG" << 'EOF'
[KDE]
widgetStyle=kvantum

[General]
ColorScheme=MaterialAdw
Name=MaterialAdw
shadeSortColumn=true

[Icons]
Theme=breeze-dark
EOF
        fi
      '';
    })
    (mkIf (config.illogical-impulse.enable && config.illogical-impulse.dotfiles.kitty.enable) {
      xdg.configFile."kitty".source = "${illogical-impulse-dotfiles}/.config/kitty";

      home.packages = [ pkgs.kitty ];
    })

    (mkIf (config.illogical-impulse.enable && config.illogical-impulse.dotfiles.starship.enable) {
      xdg.configFile."starship.toml".source = "${illogical-impulse-dotfiles}/.config/starship.toml";

      home.packages = [ pkgs.starship ];
    })
  ];
}
