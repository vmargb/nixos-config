{ config, pkgs, ... }:

{
  imports = [
    ../../common/modules
  ];

  home.packages = with pkgs; [
    mpv
    syncthing
    zathura

    fd
    ripgrep
    glow
  ];

  myDefaults.enableImports = true;
  myShell.default = "fish";
}

