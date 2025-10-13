{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

    extraConfig = {
      # run apps, fuzzy run, switch windows
      # Custom modes: Power menu, Control panel
      modi = "drun,run,window,Power:rofi-power,Control:rofi-control";
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

  # power settings
  home.file.".local/bin/rofi-power".text = ''
    #!/usr/bin/env bash
    chosen=$(printf " Power Off\n Reboot\n⏾ Suspend\n Lock\n Logout" | rofi -dmenu -i -p "Power")
    case "$chosen" in
        " Power Off") systemctl poweroff ;;
        " Reboot") systemctl reboot ;;
        "⏾ Suspend") systemctl suspend ;;
        " Lock") swaylock ;;  # change if you use another lock screen
        " Logout") loginctl terminate-user $USER ;;
    esac
  '';
  home.file.".local/bin/rofi-power".mode = "755";

  # basic control panel
  home.file.".local/bin/rofi-control".text = ''
    #!/usr/bin/env bash
    chosen=$(printf " Audio Settings\n Network\n Battery Info\n Terminal" | rofi -dmenu -i -p "Control Panel")
    case "$chosen" in
        " Audio Settings") pavucontrol ;;
        " Network") nm-connection-editor ;;
        " Battery Info") ${config.home.sessionVariables.TERMINAL:-alacritty} -e acpi -V ;;
        " Terminal") ${config.home.sessionVariables.TERMINAL:-alacritty} ;;
    esac
  '';
  home.file.".local/bin/rofi-control".mode = "755";
}

