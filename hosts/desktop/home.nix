{ config, pkgs, ... }:

{
  imports = [
    ../../common/modules
  ];

  # host-specific packages
  home.packages = with pkgs; [
    mpv
    syncthing
    zathura

    glow
  ];

  # default overrides
  myDefaults.enableImports = true;
  myShell.default = "fish";

  dev.general.enable = true;
  dev.android.enable = true;
}

