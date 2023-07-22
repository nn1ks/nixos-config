{ config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    ../modules/services/logiops.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # Firmware updates
  services.fwupd.enable = true;

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

  services.logiops = {
    enable = true;
    extraConfig = builtins.readFile ../data/logid.cfg;
  };

  services.mullvad-vpn.enable = true;

  # Use pipewire for sound.
  security.rtkit.enable = true;
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  boot.initrd.kernelModules = [ "i2c-dev" ];

  users.groups = {
    "i2c" = {}; # For controlling external monitors.
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.niklas = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "input" "kvm" "libvirtd" "i2c" ];
  };

  virtualisation.libvirtd.enable = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.just-perfection
    gnomeExtensions.gsconnect
    gnomeExtensions.adjust-display-brightness
  ];

  fonts.fonts = with pkgs; [
    iosevka
    source-han-sans
    source-serif-pro
    noto-fonts
    noto-fonts-emoji
    roboto
    babelstone-han
  ];
}

