{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];

        clock = {
          format = "{:%a %b %d  %H:%M}";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " muted";
          on-click = "pavucontrol";
          format-icons = {
            default = [ "" "" "" ];
          };
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = " {ifname}";
          tooltip = true;
        };

        battery = {
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
          interval = 30;
        };
      };
    };

    style = ''
      * {
        font-family: ${config.stylix.fonts.monospace.name}, monospace;
        font-size: 12px;
      }

      window#waybar {
        background: ${config.stylix.baseColors.background};
        color: ${config.stylix.baseColors.foreground};
      }

      #workspaces button {
        padding: 0 6px;
        color: ${config.stylix.baseColors.foreground};
      }

      #workspaces button.focused {
        background: ${config.stylix.baseColors.accent};
        color: #ffffff;
      }

      #clock,
      #pulseaudio,
      #network,
      #battery,
      #tray {
        padding: 0 10px;
      }
    '';
  };
}

