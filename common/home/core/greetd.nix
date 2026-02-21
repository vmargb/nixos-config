{ pkgs, ... }:

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
            --sessions \
            --default-session sway
        '';
        user = "greeter";
      };

      # sessions are appended
      # if other de's are enabled, such as cosmic.nix
      sessions = [
        {
          name = "sway";
          command = "${pkgs.sway}/bin/sway";
        }
      ];
    };
  };
}
