{ config, pkgs, ... }:

{
  imports = [
    ../../common/home/core
  ];

  home.packages = with pkgs; [
    syncthing
  ];

  myDefaults.enableImports = true;
  myShell.default = "fish";

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

  # dev.general.enable = true;
  # dev.cpp.enable = true;
}
