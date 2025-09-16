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

  services.xserver.displayManager.defaultSession = "niri";
}

