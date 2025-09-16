{ config, pkgs, ... }:

{
  imports = [
    ../../common/modules
  ];

  home.packages = with pkgs; [
  ];

  myDefaults.enableImports = true;
  myShell.default = "fish";
}

