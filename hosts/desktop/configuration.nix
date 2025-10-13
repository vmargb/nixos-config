{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system-base.nix
  ];

  networking.hostName = "desktop";

  # Desktop-specific packages
  environment.systemPackages = with pkgs; [
    neovim
  ];

  # stylix overrides
  #stylix = {
    #image = "/home/vmargb/.wallpapers/gruvbox.png";
    #base16Scheme = "gruvbox-dark"; #
    #fonts.monospace = "JetBrainsMono";
  #};
}

