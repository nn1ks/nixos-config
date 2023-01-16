{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        laptop = lib.nixosSystem {
          inherit system;
          modules = [
            ./laptop/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-t14
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.niklas = {
                imports = [ ./laptop/home.nix ];
              };
            }
          ];
        };
        server = lib.nixosSystem {
          inherit system;
          modules = [
            ./server/configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.niklas = {
                imports = [ ./server/home.nix ];
              };
            }
          ];
        };
      };
    };
}
