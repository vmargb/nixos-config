{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland; # wayland version

    extraConfig = {
      modi = "drun,run";
      theme = "sidebar";
      font = "${config.stylix.fonts.monospace.name} 12";
      show-icons = true;
    };

    theme = ''
      * {
        background: ${config.stylix.baseColors.background};
        foreground: ${config.stylix.baseColors.foreground};
        selected-background: ${config.stylix.baseColors.accent};
        selected-foreground: #ffffff;
      }
    '';
  };
}

