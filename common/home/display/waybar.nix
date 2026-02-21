{ pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    # Using the list format [ { ... } ] as requested
    settings = [
      {
        layer = "top";
        position = "top";
        height = 34;
        spacing = 4;
        modules-left = [ "sway/workspaces" "sway/mode" "custom/spotify" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "cpu" "temperature" "memory" "battery" "tray" ];

        "sway/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
        };

        "custom/spotify" = {
          exec = "${pkgs.playerctl}/bin/playerctl metadata --format '{{ artist }} - {{ title }}'";
          interval = 2;
          format = "  {}";
          max-length = 30;
          on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
        };

        "temperature" = {
          critical-threshold = 80;
          format = "{icon} {temperatureC}°C";
          format-icons = ["" "" ""];
        };

        "clock" = {
          format = "  {:%H:%M | %a %d}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-icons = { default = ["" "" ""]; };
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };
      }
    ];

    style = ''
      window#waybar {
        background: transparent;
      }
      .modules-left, .modules-center, .modules-right {
        background: alpha(@base00, 0.9);
        border: 1px solid @base01;
        border-radius: 10px;
        margin: 5px;
        padding: 2px 12px;
      }
      #workspaces button { padding: 0 5px; color: @base05; }
      #workspaces button.focused { color: @base0B; border-bottom: 2px solid @base0B; }
      #custom-spotify { color: @base0B; }
    '';
  };
}
