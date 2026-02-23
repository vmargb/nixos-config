{ config, pkgs, ... }:

{
  imports = [
    ../../common/home/display/sway.nix
    ../../common/home/display/waybar.nix
    ../../common/home/display/mako.nix
    ../../common/home/display/fuzzel.nix
    ../../common/home/display/idle.nix
    ../../common/home/core
  ];

  home.packages = with pkgs; [
  ];

  myShell.default = "fish";

  # Spicetify configuration
  # programs.spicetify = {
  #   enable = true;

  #   theme = inputs.spicetify-nix.themes.catppuccin;
  #   colorScheme = "mocha";

  #   enabledExtensions = with inputs.spicetify-nix.extensions; [
  #     fullAppDisplay
  #     shuffle
  #     autoSkip
  #   ];
  # };

  # dev.general.enable = true;
  # dev.cpp.enable = true;

  home.stateVersion = "25.11";
}
