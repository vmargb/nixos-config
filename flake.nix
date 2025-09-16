{
  description = "vmargb's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:nix-community/stylix";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, stylix, ... }:
    let
      # common modules available to all hosts
      sharedModules = [
        home-manager.nixosModules.home-manager
        stylix.nixosModules.stylix
      ];

      # helper function to create new hosts
      mkHost = name: system:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = sharedModules ++ [
            ./hosts/${name}/configuration.nix
            { home-manager.users.vmargb = import ./hosts/${name}/home.nix; }
          ];
        };
    in {
      nixosConfigurations = {
        laptop  = mkHost "laptop"  "x86_64-linux";
        desktop = mkHost "desktop" "x86_64-linux"; # "aarch64-darwin" for macbooks
        server = mkHost "server" "aarch64-linux"; # ARM/pi
      };
    };
}

