{ config, lib, pkgs, ... }:

{
  options.dev.general.enable = lib.mkEnableOption "Enable general dev tools and auto Nix module loading";

  config = lib.mkIf config.dev.general.enable {
    home.packages = with pkgs; [
    ];

    imports = lib.autoImportNix ./.; # auto import all core files
  };
}
