{ config, pkgs, ... }:

{
  # General Development Environment
  environment.systemPackages = with pkgs; [
    # Rust toolchain
    cargo
    rustc
    rustfmt
    rust-analyzer
    clippy

    # Go toolchain
    go
    gopls

    # Python toolchain
    python3
    python3Packages.pip
    python3Packages.virtualenv

    # General utilities often needed for compilations
    gcc
    gnumake
    jq
  ];
}
