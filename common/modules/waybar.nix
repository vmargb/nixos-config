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
          on-click = "alacritty -e cal -y"; # terminal calendar
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " muted";
          on-click = "pavucontrol";
          on-scroll-up = "pamixer -i 5"; # volume up
          on-scroll-down = "pamixer -d 5"; # volume down
          format-icons = {
            default = [ "" "" "" ];
          };
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = " {ifname}";
          tooltip = true;
          on-click = "nm-connection-editor"; # networkmanager editor
        };

        battery = {
          format = "{capacity}% {icon}";
          format-icons = [ "" "" "" "" "" ];
          interval = 30;
          on-click = "foot -e acpi -V"; # show extra battery info in terminal
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

