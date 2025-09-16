{ config, pkgs, ... }:

{
  programs.niri = {
    enable = true;
    settings = {
      startup = [
        "waybar"
        "dunst"
        "eww daemon"
        "foot --server"
      ];
      keybindings = {
        "Mod+Return" = "spawn footclient";
        "Mod+D" = "spawn rofi -show drun";
        "Mod+E" = "spawn emacsclient -c -a emacs";
      };
    };
  };
}

