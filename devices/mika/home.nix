{ config, pkgs, ... }:

{
  imports = [ ../../base/home.nix ];

  home = {
    stateVersion = "22.11";
  };
}
