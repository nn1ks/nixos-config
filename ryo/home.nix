{ config, pkgs, pkgs-unstable, ... }:

{
  imports = [ ../base/desktop-home.nix ];

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      openrgb
    ];
  };
}

