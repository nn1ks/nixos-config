{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../modules/nixos/logiops.nix
  ];

  nix = {
    settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    extraOptions = "experimental-features = nix-command flakes";
  };

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Automatically update microcode
  hardware.cpu.amd.updateMicrocode = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Use zram swap.
  zramSwap = {
    enable = true;
    memoryMax = 32000000000; # 32GB
  };

  hardware.opengl.extraPackages = [ pkgs.rocm-opencl-icd pkgs.amdvlk ];

  networking.hostName = "t14-nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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
    noto-fonts
    noto-fonts-emoji
    roboto
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}

