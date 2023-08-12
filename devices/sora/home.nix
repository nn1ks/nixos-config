{ config, pkgs, ... }:

{
  imports = [ ../../base/home.nix ];

  home = {
    stateVersion = "23.05";
  };
}
