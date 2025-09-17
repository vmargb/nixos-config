{ config, pkgs, ... }:

{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        font = "${config.stylix.fonts.monospace.name} 10";
        frame_color = config.stylix.baseColors.base01;
        separator_color = "frame";
        transparency = 10;
        follow = "keyboard";
      };

      urgency_low = {
        background = config.stylix.baseColors.background;
        foreground = config.stylix.baseColors.base05;
      };

      urgency_normal = {
        background = config.stylix.baseColors.base01;
        foreground = config.stylix.baseColors.foreground;
      };

      urgency_critical = {
        background = config.stylix.baseColors.red;
        foreground = config.stylix.baseColors.foreground;
        frame_color = config.stylix.baseColors.red;
      };
    };
  };
}

