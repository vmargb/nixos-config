{ config, pkgs, ... }:

{
  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "foot";
      menu = "fuzzel";
      
      gaps = {
        inner = 10;
        outer = 5;
      };

      bars = [{ command = "${pkgs.waybar}/bin/waybar"; }];

      # use the wallpaper defined in stylix.nix
      output = {
        "*" = {
          bg = "${config.stylix.image} fill";
        };
      };
    };
  };

  programs.swaylock = {
    enable = true;
    settings = {
      image = "${config.stylix.image}"; # lock screen uses wallpaper
      scaling = "fill";
      indicator-radius = 100;
      indicator-thickness = 7;
    };
  };
}
