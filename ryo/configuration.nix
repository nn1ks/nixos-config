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

  networking.hostName = "ryo";
  networking.networkmanager.enable = true;

  services.udev = {
    enable = true;
    extraRules = ''KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0",RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0",RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"'';
  };
}
