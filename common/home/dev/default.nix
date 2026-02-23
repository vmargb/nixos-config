{ config, lib, pkgs, ... }:

let
  cfg = config.dev.general;
in
{
  options.dev.general.enable = lib.mkEnableOption "Enable general dev tools and auto Nix module loading";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
    ];

    imports = [
      ./rust.nix
      ./cpp.nix
      ./python.nix
      ./node.nix
    ];
  };
}
