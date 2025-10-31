{ config, pkgs, lib, ... }:

{
  config = {
    home.username = "vmargb";
    home.homeDirectory = "/home/vmargb";

    home.packages = with pkgs; [
      fastfetch
      wl-clipboard
      grim # screenshots
      slurp # region screenshots
      tree
      libnotify # notifcation send
    ];

    imports = lib.autoImportNix ./.; # auto import all core files
  };
}
