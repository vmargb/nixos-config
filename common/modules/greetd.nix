{ config, pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.greetd.tuigreet}/bin/tuigreet \
            --time \
            --asterisks \
            --user-menu \
            --sessions
        '';
        user = "greeter";
      };

      sessions = [
        {
          name = "niri";
          command = "${pkgs.niri}/bin/niri";
        }
        {
          name = "sway";
          command = "${pkgs.sway}/bin/sway";
        }
        {
          name = "kde";
          command = "${pkgs.plasma-workspace}/bin/startplasma-wayland";
        }
      ];
    };
  };

  # stylix theming for tuigreet
  stylix.targets.greetd.enable = true;
}

