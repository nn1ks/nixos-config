{ config, pkgs, ... }:

{
  imports = [
    ../base/configuration.nix
    ./hardware-configuration.nix
    ../modules/nixos/logiops.nix
  ];

  # Automatically update microcode
  hardware.cpu.amd.updateMicrocode = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Use zram swap.
  zramSwap = {
    enable = true;
    memoryMax = 32000000000; # 32GB
  };

  hardware.opengl = {
    extraPackages = [ pkgs.rocm-opencl-icd pkgs.amdvlk ];
    driSupport32Bit = true;
  };

  networking.hostName = "t14-nixos";
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.layout = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.auto-cpufreq.enable = true;

  services.btrbk.instances.main.settings = {
    volume = {
      "/" = {
        subvolume."@home" = {
          snapshot_dir = ".btrbk-snapshots";
          target = "/run/media/niklas/cfcdd493-3fed-47d3-aeb7-a83ec80e7c89/t14-nixos-backup";
          snapshot_preserve_min = "1w";
          snapshot_preserve = "7d 2w";
          target_preserve_min = "1w";
          target_preserve = "20d 10w 10m *y";
        };
      };
    };
  };

  services.logiops = {
    enable = true;
    extraConfig = builtins.readFile ../data/logid.cfg;
  };

  # Use pipewire for sound.
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    media-session.config.bluez-monitor = pkgs.lib.importJSON ../data/bluez-monitor.conf.json;
  };

  users.groups = {
    "i2c" = {}; # For controlling external monitors.
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.niklas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "input" "kvm" "libvirtd" "i2c" ];
  };

  services.udev = {
    enable = true;
    extraRules = ''KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0",RUN+="${pkgs.coreutils}/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="amdgpu_bl0",RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/backlight/%k/brightness"'';
  };

  virtualisation.libvirtd.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.just-perfection
    gnomeExtensions.gsconnect
  ];

  fonts.fonts = with pkgs; [
    iosevka
    source-han-sans
    source-serif-pro
    noto-fonts
    noto-fonts-emoji
    roboto
  ];
}
