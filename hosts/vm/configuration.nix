{ lib, pkgs, ... }:
let
  fenosVmSessionLauncher = pkgs.writeShellScript "fenos-vm-session-launcher" ''
    set -euo pipefail
    exec ${pkgs.bash}/bin/bash -lc 'exec dbus-run-session sh -lc "Hyprland || exec sway"'
  '';
in
{
  imports = [
    ../default/configuration.nix
  ];

  # VM-only initrd drivers.
  boot.initrd.availableKernelModules = lib.mkAfter [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
  ];

  # VM-only compositor fallback to avoid blank sessions on fragile virtual GPUs.
  services.greetd.settings.default_session = {
    command = lib.mkForce "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${fenosVmSessionLauncher}";
    user = lib.mkForce "greeter";
  };
}
