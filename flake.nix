{
  description = "vmargb's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:nix-community/stylix";
    nixcord.url = "github:kaylorben/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, stylix, ... }:
    let
      # extend nixpkgs.lib with auto-import
      lib = nixpkgs.lib.extend (final: prev:
        let
          helpers = import ./lib/auto-import.nix { lib = prev; };
        in helpers
      );
      # load and activate these modules automatically
      baseModules = [ home-manager.nixosModules.home-manager ];
      desktopModules = baseModules ++ [ stylix.nixosModules.stylix ];
      mkHost = { name, system, isDesktop ? true }: # helper function to create new hosts
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = (if isDesktop then desktopModules else baseModules) ++ [
            ./hosts/${name}/configuration.nix
            {
              home-manager.useGlobalPkgs = true; # avoid pkg duplication
              home-manager.useUserPackages = true; # store pkgs in bin
              home-manager.users.vmargb = import ./hosts/${name}/home.nix {
                inherit inputs lib; # pass inputs & lib without loading (lazy)
              };
              home-manager.users.vmargb.backupFileExtension = "hm-bak";
            }
          ];
          # pass extended lib to all nixos modules via specialArgs
          specialArgs = { inherit lib; } # does not include home.nix
        };
    in {
      nixosConfigurations = {
        laptop  = mkHost { name = "laptop";  system = "x86_64-linux"; }; # "aarch64-darwin" for Apple
        desktop = mkHost { name = "desktop"; system = "x86_64-linux"; };
        server  = mkHost { name = "server";  system = "aarch64-linux"; isDesktop = false; };
      };
    };
}
