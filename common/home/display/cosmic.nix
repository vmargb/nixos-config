{ config, pkgs, lib, ... }:

{
  options.myCosmic.enable = lib.mkEnableOption "Enable COSMIC DE";

  config = lib.mkIf config.myCosmic.enable { # apply only if the option is enabled

    services.cosmic-de.enable = true;

    home.packages = with pkgs; [
      cosmic-term
      cosmic-files
      cosmic-settings
      cosmic-edit
    ];

    # automatically add the COSMIC session to greetd if its enabled
    services.greetd.settings.sessions = [
      {
        name = "cosmic";
        command = "${pkgs.cosmic-session}/bin/cosmic-session";
      }
    ];
  };
}