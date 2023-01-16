# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [ "nvme" "ehci_pci" "xhci_pci" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7f5eda9e-6705-486f-985f-288ec66839ce";
    fsType = "btrfs";
    options = [ "subvol=@" "compress-force=zstd" "noatime" ];
  };

  boot.initrd.luks.devices."nixenc".device = "/dev/disk/by-uuid/ae197117-8ebe-428c-bcf3-792d33c72483";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6ACE-E141";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7f5eda9e-6705-486f-985f-288ec66839ce";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress-force=zstd" "noatime" ];
  };

  # External disk for backups
  # fileSystem."/run/media/niklas/backup" = {
  #   device = "/dev/disk/by-uuid/cfcdd493-3fed-47d3-aeb7-a83ec80e7c89";
  #   fsType = "btrfs";
  #   options = [ "subvol=@t14-nixos-backup" "compress-force=zstd:9" "noatime" "nosuid" "nodev" "nofail" "noauto" ];
  # };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp5s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
