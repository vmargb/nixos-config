{ config, pkgs, lib, inputs ... }:

{
  imports = [
    ../../common/home/core
    inputs.nixcord.homeManagerModules.nixcord
    inputs.spicetify-nix.homeManagerModules.default
  ];

  # host-specific packages
  home.packages = with pkgs; [
    mpv
    zathura
    tealdeer
    glow
  ];

  # vencord
  programs.nixcord = {
    enable = true;
    client = "vencord";
  };

  # Spicetify configuration
  programs.spicetify = {
    enable = true;

    theme = inputs.spicetify-nix.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with inputs.spicetify-nix.extensions; [
      fullAppDisplay
      shuffle
      autoSkip
    ];
  };

  # default overrides
  myDefaults.enableImports = true;
  myShell.default = "fish";

  # wm overrides
  #myCosmic.enable = true;

  # dev.general.enable = true;
  # dev.android.enable = false;
}

