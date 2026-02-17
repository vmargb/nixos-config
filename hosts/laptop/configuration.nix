{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system/base.nix
    ../../common/system/theme.nix
  ];

  networking.hostName = "laptop";

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
  ];

  # stylix overrides
  #stylix = {
    #image = "/home/vmargb/.wallpapers/gruvbox.png";
    # base16Scheme = "gruvbox-dark"; #
    # fonts.monospace = "JetBrainsMono";
  #};

  networking.networkmanager.wifi.powersave = true; # power saving for laptop only

  system.stateVersion = "25.11"; # for nixos-rebuild compatibility, update when changing nixpkgs version
}

