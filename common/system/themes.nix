{ lib, config, pkgs, ... }:

{
  # only apply if Stylix is available (so servers won’t complain)
  stylix = lib.mkIf (config ? stylix) {
    enable = true;

    # Wallpaper / background
    image = "/home/vmargb/wallpapers/gruvbox.png";

    # you can use base16 themes, Catppuccin, etc.
    # base16Scheme = "gruvbox-dark"; # optional manual theme
    # stylix has built-in schemes too:
    # scheme = "catppuccin-mocha";

    # Font setup
    fonts = {
      serif = "Noto Serif";
      sansSerif = "Noto Sans";
      monospace = "Iosevka";
      emoji = "Noto Color Emoji";
    };

    # cursor theme
    cursor = {
      package = pkgs.capitaine-cursors;
      name = "Capitaine Cursors (Gruvbox)";
      size = 24;
    };

    # GTK & Qt theming
    gtk = {
      enable = true;
      theme = {
        name = "Gruvbox-Dark";
        package = pkgs.gruvbox-gtk-theme;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk"; # unify Qt + GTK
    };
  };
}
