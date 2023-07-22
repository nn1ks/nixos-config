{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [ ./home.nix ];

  home.packages = with pkgs; [
    # Development
    gcc
    ccls
    python3

    # Other
    pwgen
    translate-shell
    trash-cli
    youtube-dl
    zip
    unzip
    gnome.gnome-tweaks
    gnome.gnome-boxes
    pkgs-unstable.blackbox-terminal
    pkgs-unstable.fractal-next
    fragments
    spotify
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
