{ config, pkgs, lib, ... }:

let
  homeDir = config.home.homeDirectory;
  wallpaperPath = "${homeDir}/wallpapers/gruvbox.png";
  wallpaperExists = builtins.pathExists wallpaperPath;
in {
  stylix = {
    enable = true;

    extra = [ # pull in base-16 schemes automatically
      pkgs.base16-schemes
    ];

    # fallback only use the image if it exists
    image = lib.mkIf wallpaperExists wallpaperPath;
    # explicit colour scheme as backup
    base16Scheme =
      "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

    polarity = "dark";

    fonts = {
      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      monospace = {
        package = pkgs.iosevka;
        name = "Iosevka";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      cursor = {
        package = pkgs.phinger-cursors;
        name = "phinger-cursors";
        size = 24;
      };
    };
  };
}
