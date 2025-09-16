{ config, pkgs, ... }:

{
  imports = [
    ../../common/modules
  ];

  myDefaults.enableImports = true;

  home.packages = with pkgs; [
  ];

}

