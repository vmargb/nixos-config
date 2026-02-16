{
  description = "vmargb's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:nix-community/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    nixcord.url = "github:kaylorben/nixcord";
    nixcord.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, stylix, ... }:
    let
      lib = nixpkgs.lib;
      baseModules = [ home-manager.nixosModules.home-manager ];
      desktopModules = baseModules ++ [
        stylix.nixosModules.stylix
        noctalia.nixosModules.default
      ];

      # helper function to create hosts with explicit module composition
      mkHost = { name, system, isDesktop ? true }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = (if isDesktop then desktopModules else baseModules) ++ [
            ./hosts/${name}/configuration.nix
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.vmargb = import ./hosts/${name}/home.nix {
                inherit inputs lib;
              };
              home-manager.users.vmargb.backupFileExtension = "hm-bak";
            }
          ];
        };
    in {
      nixosConfigurations = {
        laptop  = mkHost { name = "laptop";  system = "x86_64-linux"; };
        desktop = mkHost { name = "desktop"; system = "x86_64-linux"; };
        server  = mkHost { name = "server";  system = "aarch64-linux"; isDesktop = false; };
      };
    };
}
