{ config, ... }:

{
  programs.foot = {
    enable = true;

    settings = {
      main = {
        font = "${config.stylix.fonts.monospace.name}:size=12";
      };

      scrollback = {
        lines = 10000;
      };

      colors = {
        foreground = config.stylix.baseColors.foreground;
        background = config.stylix.baseColors.background;
      };
    };
  };
}

