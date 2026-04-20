illogical-impulse-dotfiles: inputs: { config, lib, pkgs, ... }:
let
  cfg = config.illogical-impulse;
in
{
  config = lib.mkIf cfg.enable {
    gtk = {
      enable = true;
      gtk4.theme = null;
      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };
    };
    qt = {
      enable = true;
      platformTheme.name = "kde";
      style.name = "kvantum";
    };
    home.sessionVariables = {
      ILLOGICAL_IMPULSE_VIRTUAL_ENV = "~/.local/state/quickshell/.venv";
      QT_STYLE_OVERRIDE = "kvantum";
      KVANTUM_THEME = "MaterialAdw";
    };

    home.packages = with pkgs; [
      quickshell
      kdePackages.kdialog
      kdePackages.qt5compat
      kdePackages.qtbase
      kdePackages.qtdeclarative
      kdePackages.qtdeclarative
      kdePackages.qtimageformats
      kdePackages.qtmultimedia
      kdePackages.qtpositioning
      kdePackages.qtquicktimeline
      kdePackages.qtsensors
      kdePackages.qtsvg
      kdePackages.qttools
      kdePackages.qttranslations
      kdePackages.qtvirtualkeyboard
      kdePackages.qtwayland
      kdePackages.syntax-highlighting
      qt6Packages.qtstyleplugin-kvantum
    ];

    xdg.configFile."quickshell".source = "${illogical-impulse-dotfiles}/.config/quickshell";
    xdg.configFile."Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=MaterialAdw
    '';
  };
}
