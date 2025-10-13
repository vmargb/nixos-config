{
  description = "vmargb's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
            {
              home-manager.useGlobalPkgs = true; # avoid pkg duplication
              home-manager.useUserPackages = true; # store pkgs in bin
              home-manager.users.vmargb = import ./hosts/${name}/home.nix;
              home-manager.users.vmargb.backupFileExtension = "hm-bak";
            }
          ];
        };
    in {
      nixosConfigurations = {
        laptop  = mkHost "laptop"  "x86_64-linux";
        desktop = mkHost "desktop" "x86_64-linux"; # "aarch64-darwin" for Apple
        server = mkHost "server" "aarch64-linux"; # ARM
      };
    };
}

