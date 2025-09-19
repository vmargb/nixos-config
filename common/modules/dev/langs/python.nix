{ config, lib, pkgs, ... }:

{
  options.dev.python.enable = lib.mkEnableOption "Enable Python dev tools";

  config = lib.mkIf config.dev.python.enable {
    home.packages = with pkgs; [
      python3
      python3Packages.pip
      python3Packages.virtualenv
      poetry
      (pkgs.python3.withPackages (ps: with ps; [
        requests numpy pandas black mypy
      ]))
    ];
  };
}

