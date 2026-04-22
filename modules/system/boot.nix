{
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "usbhid"
    "usb_storage"
    "uas"
    "sr_mod"
    "ahci"
    "sd_mod"
  ];

  boot.initrd.luks.devices."crypted" = {
    device = "/dev/disk/by-partlabel/disk-main-luks";
    preLVM = true;
    allowDiscards = true;
  };

  # Required so initrd ships btrfs userland (matches the disko layout
  # used by `feninstall`: LUKS -> LVM -> btrfs on root and home).
  boot.supportedFilesystems = [ "btrfs" ];

  fileSystems."/" = {
    device = "/dev/mapper/crypted--vg-root";
    fsType = "btrfs";
    options = [ "compress=zstd:1" "noatime" "ssd" "space_cache=v2" ];
  };

  fileSystems."/home" = {
    device = "/dev/mapper/crypted--vg-home";
    fsType = "btrfs";
    options = [ "compress=zstd:1" "noatime" "ssd" "space_cache=v2" ];
  };

  swapDevices = [
    { device = "/dev/mapper/crypted--vg-swap"; }
  ];

  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/disk-main-ESP";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.cleanOnBoot = true;

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };
}
