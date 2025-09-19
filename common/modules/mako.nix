{ config, pkgs, ... }:

{
  services.mako = {
    enable = true;
    stylix.enable = true; # automatically applies colors + fonts

    extraConfig = ''
      default-timeout=5000
      border-size=2
      padding=8
      margin=10
      icons=1
      font=${config.stylix.fonts.monospace.name} 11
    '';
  };
}

