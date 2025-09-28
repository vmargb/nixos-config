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

      # only niri which is the main, sessions are appended
      # if other de's are enabled, such as cosmic.nix
      sessions = [
        {
          name = "niri";
          command = "${pkgs.niri}/bin/niri";
        }
      ];
    };
  };

  # stylix theming for tuigreet
  stylix.targets.greetd.enable = true;
}

