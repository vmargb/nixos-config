{ config, lib, pkgs, ... }:

{
  options.dev.node.enable = lib.mkEnableOption "Enable Node.js dev tools";

  config = lib.mkIf config.dev.node.enable {
    home.packages = with pkgs; [
      nodejs_20 yarn
    ];
  };
}

