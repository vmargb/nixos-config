{ config, lib, pkgs, ... }:

{
  options.dev.rust.enable = lib.mkEnableOption "Enable Rust dev tools";

  config = lib.mkIf config.dev.rust.enable {
    home.packages = with pkgs; [
      rustup
      cargo
      rust-analyzer
    ];
  };
}

