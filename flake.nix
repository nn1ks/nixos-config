{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixos-hardware, home-manager, agenix }:
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
      agenix-package = agenix.packages."${system}".default;
    in {
      nixosConfigurations = {
        # Desktop
        kiyo = lib.nixosSystem {
          inherit system;
          modules = [
            ./devices/kiyo/configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
              home-manager.users.niklas = {
                imports = [ ./devices/kiyo/home.nix ];
              };
            }
            agenix.nixosModules.default
            { environment.systemPackages = [ agenix.packages."${system}".default ]; }
          ];
        };

        # Laptop
        aiko = lib.nixosSystem {
          inherit system;
          modules = [
            ./devices/aiko/configuration.nix
            nixos-hardware.nixosModules.lenovo-thinkpad-t14
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
              home-manager.users.niklas = {
                imports = [ ./devices/aiko/home.nix ];
              };
            }
            agenix.nixosModules.default
            { environment.systemPackages = [ agenix.packages."${system}".default ]; }
          ];
        };

        # VPS
        # TODO: Use `lib.nixosSystem` (without `nixpkgs-unstable`) once the updated lemmy service is available in the stable version
        mika = nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit pkgs-unstable; };
          modules = [
            ./devices/mika/configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit pkgs-unstable; };
              home-manager.users.niklas = {
                imports = [ ./devices/mika/home.nix ];
              };
            }
            agenix.nixosModules.default
            { environment.systemPackages = [ agenix.packages."${system}".default ]; }
          ];
        };
      };
    };
}
