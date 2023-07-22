{ config, pkgs, pkgs-unstable, ... }:

let
  customBitwigStudio = pkgs.callPackage ../../modules/packages/bitwig-studio4.nix  {};
in
{
  imports = [ ../../base/desktop-home.nix ];

  home = {
    stateVersion = "22.11";
    packages = with pkgs; [
      # Audio
      customBitwigStudio
      pipewire.jack
      helvum
      yabridge
      yabridgectl
      lsp-plugins
      CHOWTapeModel
      ChowPhaser
      ChowCentaur
      dragonfly-reverb
      guitarix
      gxplugins-lv2
    ];
  };
}

