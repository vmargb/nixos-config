{ config, pkgs, ... }:

{
  imports = [
    ../../common/modules
  ];

  myDefaults.enableImports = true;

  home.packages = with pkgs; [
    mpv
    syncthing
    zathura

    fd
    ripgrep
    glow
  ];

}

