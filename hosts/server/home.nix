{ config, pkgs, ... }:

{
  imports = [
    ../../common/home/core
  ];

  home.packages = with pkgs; [
    syncthing
  ];

  myDefaults.enableImports = false;
}
