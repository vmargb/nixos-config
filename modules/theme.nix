{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.base16-schemes ];

  stylix = {
    enable = true;

    # gruvbox-material-dark-medium theme as default theme
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";

    # solid dark placeholder background to satisfy stylix requirements
    # when background image not available
    image = pkgs.runCommand "solid-bg.png" {} ''
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 xc:"#282828" $out
    '';

    fonts = {
      monospace = {
        name = "Iosevka";
        package = pkgs.iosevka;
      };

      sansSerif = {
        name = "Iosevka";
        package = pkgs.iosevka;
      };

      serif = {
        name = "Iosevka";
        package = pkgs.iosevka;
      };

      sizes = {
        terminal = 12;
        applications = 11;
        desktop = 11;
      };
    };

    # stylix targets
    targets.niri.enable = true;
    targets.alacritty.enable = true;
    targets.gtk.enable = true;

    # icon packs
    iconTheme = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
  };
}
