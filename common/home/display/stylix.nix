{ config, pkgs, inputs, ... }:

{
  stylix = {
    enable = true;
    image = config.home.homeDirectory + "/wallpapers/gruvbox.png";
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
        package = pkgs.iosevka;  # Your original choice
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
