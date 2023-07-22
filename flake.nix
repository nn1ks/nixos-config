{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      lib = nixpkgs.lib;
    in {
      nixosConfigurations = {
        # Desktop
        ryo = lib.nixosSystem {
          inherit system;
          modules = [
            ./ryo/configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
              home-manager.users.niklas = {
                imports = [ ./ryo/home.nix ];
              };
            }
          ];
        };

        # Laptop
        kita = lib.nixosSystem {
          inherit system;
          modules = [
            ./kita/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-t14
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
              home-manager.users.niklas = {
                imports = [ ./kita/home.nix ];
              };
            }
          ];
        };

        # Server
        # TODO: Use `lib.nixosSystem` (without `nixpkgs-unstable`) once the updated lemmy service is available in the stable version
        sakura = nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs-unstable; };
          modules = [
            ./sakura/configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
              home-manager.users.niklas = {
                imports = [ ./sakura/home.nix ];
              };
            }
          ];
        };
      };
    };
}
