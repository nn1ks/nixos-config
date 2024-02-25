{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [ ./home.nix ];

  home.packages = with pkgs; [
    gcc
    ccls
    python3
    direnv
    nix-direnv
    nil
    vscodium
    pwgen
    translate-shell
    trash-cli
    youtube-dl
    zip
    unzip
    gnome.gnome-tweaks
    gnome.gnome-boxes
    pkgs-unstable.blackbox-terminal
    fragments
    spotify
    pkgs-unstable.youtube-music
    discord
    steam
    fragments
    qbittorrent
    celluloid
    bitwarden
    gimp
    xournalpp
    rnote
    restic
    wineWowPackages.waylandFull
    winetricks
    dxvk
    legendary-gl
    lutris
    mullvad-vpn
    bluez
    ddcutil
    xdg-utils
    tor-browser-bundle-bin
    tiled
    libresprite
    pika-backup
  ];

  programs.firefox.enable = true;

  programs.git.signing = {
    key = "F4047D8CF4CCCBD7F04CAC4446D2BA9AB7079F73";
    signByDefault = true;
  };

  services.syncthing.enable = true;

  dconf.settings = {
    "org/gnome/mutter" = {
      experimental-features = [ "scale-monitor-framebuffer" ];
    };
  };
}
