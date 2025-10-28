{ lib, config, pkgs, ... }:

{
  # only apply if Stylix is available as flake input
  stylix = lib.mkIf (config ? stylix) {
    enable = true;

    # Wallpaper / background
    image = "/home/vmargb/.wallpapers/gruvbox.png";

    # You can use base16 themes, Catppuccin, etc.
    # base16Scheme = "gruvbox-dark"; # optional manual theme
    # Alternatively, stylix has built-in schemes too:
    # scheme = "catppuccin-mocha";

    # Font setup
    fonts = {
      serif = "Noto Serif";
      sansSerif = "Noto Sans";
      monospace = "Iosevka";
      emoji = "Noto Color Emoji";
    };

    # Optionally define cursor + icon theme
    cursor = {
      package = pkgs.capitaine-cursors;
      name = "Capitaine Cursors (Gruvbox)";
      size = 24;
    };

    # GTK & Qt theming (optional)
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
