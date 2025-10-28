{ config, pkgs, ... }:

{
  imports = [
    ../../common/home
  ];

  home.packages = with pkgs; [
  ];

  myDefaults.enableImports = true;
  myShell.default = "fish";

  dev.general.enable = true;
  dev.cpp.enable = true;
}
