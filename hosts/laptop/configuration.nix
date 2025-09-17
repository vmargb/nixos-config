{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/system-base.nix
  ];

  networking.hostName = "laptop";

  # Laptop-specific packages
  environment.systemPackages = with pkgs; [
    neovim
  ];

  # stylix overrides
  #stylix = {
    #image = "/home/vmargb/.wallpapers/gruvbox.png";
    # base16Scheme = "gruvbox-dark"; #
    # fonts.monospace = "JetBrainsMono";
  #};

  services.xserver.displayManager.defaultSession = "niri";
}

