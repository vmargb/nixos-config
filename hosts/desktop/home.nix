{ config, pkgs, ... }:

{
  imports = [
    ../../common/modules
  ];

  # host-specific packages
  home.packages = with pkgs; [
    mpv
    zathura
    tealdeer
    glow
  ];

  # default overrides
  myDefaults.enableImports = true;
  myShell.default = "fish";

  # wm overrides
  #myCosmic.enable = true;

  dev.general.enable = true;
  dev.android.enable = true;
}

