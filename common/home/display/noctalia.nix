{ config, pkgs, inputs, ... }:

{
  programs.noctalia-shell = {
    enable = true;
    
    # Package from flake input
    package = inputs.noctalia.packages.${pkgs.system}.default;
    
    # Enable systemd service for auto-start
    systemdTarget = "graphical-session.target";
  };

  # Integrate with Stylix for automatic theming
  programs.noctalia-shell.settings = {
    # Layout and behavior
    layout = {
      bar = {
        height = 36;
        margin = [ 8 8 0 8 ];
      };
      notification = {
        position = "top-right";
      };
    };

    # Use Stylix generated colors (auto-applies base16 theme)
    colors = config.stylix.base16Colors.extend {
      # Override specific Noctalia colors with Stylix palette
      primary = config.stylix.base16Colors.base0D;      # Selection blue
      on-primary = config.stylix.base16Colors.base00;   # Background
      primary-container = config.stylix.base16Colors.base01;
      on-primary-container = config.stylix.base16Colors.base05;
      
      # Full Stylix integration - use generated palette
      background = config.stylix.base16Colors.base00;
      surface = config.stylix.base16Colors.base01;
      "on-surface" = config.stylix.base16Colors.base05;
    };

    # Enable useful templates
    templates.activeTemplates = [
      {
        id = "kitty";
        active = true;
      }
      {
        id = "spicetify";
        active = true;
      }
    ];

    # Keybinds (configured via compositor)
    keybinds = {
      "SUPER+SHIFT+q" = "ipc call window close";
      "SUPER+SHIFT+r" = "ipc call layout restart";
    };
  };
}
