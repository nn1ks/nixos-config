{ config, pkgs, ... }:

{
  imports = [ ../base/home.nix ];

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      # Development
      rustup
      rust-analyzer
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
      blackbox-terminal
      spotify
      discord
      fragments
      celluloid
      bitwarden
      gimp
      xournalpp
      rnote
      restic
      wine64
      winetricks
      legendary-gl
      lutris
      bluez
      ddcutil
      xdg-utils
      texlive.combined.scheme-full
    ];
  };

  programs = {
    firefox.enable = true;

    git.signing = {
      key = "F4047D8CF4CCCBD7F04CAC4446D2BA9AB7079F73";
      signByDefault = true;
    };
  };
}

