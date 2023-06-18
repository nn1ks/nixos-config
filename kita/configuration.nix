{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../base/desktop-configuration.nix
  ];

  # Automatically update microcode
  hardware.cpu.amd.updateMicrocode = true;

  # Use zram swap.
  zramSwap = {
    enable = true;
    memoryMax = 32000000000; # 32GB
  };

  hardware.opengl = {
    extraPackages = [ pkgs.rocm-opencl-icd pkgs.amdvlk ];
    driSupport32Bit = true;
  };

  networking.hostName = "kita";
  networking.networkmanager.enable = true;

  services.btrbk.instances.btrbk.settings = {
    volume = {
      "/" = {
        subvolume."home" = {
          snapshot_dir = ".btrbk-snapshots";
          target = "/run/media/niklas/backup";
          snapshot_preserve_min = "1w";
          snapshot_preserve = "7d 2w";
          target_preserve_min = "1w";
          target_preserve = "20d 10w 10m *y";
        };
      };
    };
  };

  services.fprintd.enable = true;

  services.udev = {
    enable = true;
    extraRules = ''KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0",RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0",RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"'';
  };
}
