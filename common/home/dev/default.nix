{ config, lib, pkgs, ... }:

{
  options.dev.general.enable = lib.mkEnableOption "Enable general dev tools and auto Nix module loading";

  config = lib.mkIf config.dev.general.enable {
    home.packages = with pkgs; [
    ];

    imports = [
      ./rust.nix
      ./cpp.nix
      ./python.nix
      ./node.nix
    ]
  };
}
