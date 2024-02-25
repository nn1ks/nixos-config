## Updating flake

Run `nix flake update` to update the flake. Then copy the `flake.lock` file to `flake-<device>.lock` and commit it to the repository.


## Building and switching generation

Run `sudo nixos-rebuild switch --flake .` to switch to a new NixOS generation.