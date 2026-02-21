{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system/base.nix
  ];

  networking.hostName = "laptop";

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
  ];
  
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # Required for swaylock to work
  security.pam.services.swaylock = {};

  # Portals for screen sharing and file picking
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # stylix overrides
  #stylix = {
    #image = "/home/vmargb/.wallpapers/gruvbox.png";
    # base16Scheme = "gruvbox-dark"; #
    # fonts.monospace = "JetBrainsMono";
  #};

  networking.networkmanager.wifi.powersave = true; # power saving for laptop only

  system.stateVersion = "25.11"; # for nixos-rebuild compatibility, update when changing nixpkgs version
}

