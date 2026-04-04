{ ... }:
{
  imports = [
    ../default/configuration.nix
  ];

  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos#pc";
    operation = "switch";
    dates = "daily";
    randomizedDelaySec = "45min";
    allowReboot = true;
    rebootWindow = {
      lower = "03:00";
      upper = "05:00";
    };
  };
}
