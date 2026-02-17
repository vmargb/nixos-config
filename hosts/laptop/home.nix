{ config, pkgs, ... }:

{
  imports = [
    ../../common/home/display/wm.nix
    ../../common/home/display/noctalia.nix
    ../../common/home/core
  ];

  home.packages = with pkgs; [
  ];

  myDefaults.enableImports = true;
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
}
