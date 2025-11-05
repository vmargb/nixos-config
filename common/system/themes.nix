{
  stylix = {
    enable = true;

    image = "/home/vmargb/wallpapers/gruvbox.png";  # wallpapers path
    # base16Scheme = "gruvbox-dark";  # for explicit theme

    polarity = "dark";  # or "light

    fonts = {
      serif = "Noto Serif";
      sansSerif = "Noto Sans";
      monospace = "Iosevka";
      emoji = "Noto Color Emoji";
    };

    cursor = {
      package = pkgs.capitaine-cursors;
      name = "Capitaine Cursors (Gruvbox)";
      size = 24;
    };

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
      platformTheme = "gtk";
    };
  };
}
