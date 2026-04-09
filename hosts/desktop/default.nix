{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader for x86 usually uses systemd-boot for EFI
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";

  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    # desktop-only packages
  ];
}
