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

  services.xserver.displayManager.defaultSession = "niri";
}

