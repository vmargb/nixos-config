{ config, lib, pkgs, ... }:

let
  cfg = config.dev.general;
in
{
  options.dev.general.enable = lib.mkEnableOption "Enable general dev tools and auto Nix module loading";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Add general dev tools here if needed
    ];

    imports = [
      ./rust.nix
      ./cpp.nix
      ./python.nix
      ./node.nix
    ];
  };
}
