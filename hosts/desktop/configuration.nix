{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system/base.nix
    ../../common/system/theme.nix
  ];

  networking.hostName = "desktop";

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
  ];

  # stylix overrides
  #stylix = {
    #image = "/home/vmargb/.wallpapers/gruvbox.png";
    #base16Scheme = "gruvbox-dark"; #
    #fonts.monospace = "JetBrainsMono";
  #};
}

