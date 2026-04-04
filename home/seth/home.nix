{ inputs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./modules/base.nix
    ./modules/desktop.nix
    ./modules/kitty.nix
    ./modules/nixvim.nix
  ];

  home.username = "seth";
  home.homeDirectory = "/home/seth";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
