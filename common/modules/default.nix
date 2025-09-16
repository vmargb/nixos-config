{ config, pkgs, lib, ... }:

{
  # consistent user identity
  home.username = "vmargb";
  home.homeDirectory = "/home/vmargb";

  # packages for all hosts (appendable)
  home.packages = lib.mkAfter (with pkgs; [
    fastfetch
    wl-clipboard # clipboard to terminal
    grim # screenshots
    slurp # region-based screenshots
    tree # tree hierarchy
  ]);

  # toggle module imports below
  options.myDefaults.enableImports = lib.mkEnableOption "Enable standard module imports";

  # standard modules for every host (toggleable)
  imports = lib.mkIf (config.myDefaults.enableImports or false) [
    ./shells.nix
    ./foot.nix
    ./emacs.nix
    ./niri.nix
    ./waybar.nix
    ./rofi.nix
    ./dunst.nix
    ./greetd.nix
  ];

  # symlinks (always applied, independent of imports)
  xdg.configFile = {
    "fish/config.fish".source     = ../../dotfiles/fish/config.fish;
    "zsh/.zshrc".source           = ../../dotfiles/zsh/.zshrc;
    "starship/starship.toml".source = ../../dotfiles/starship/starship.toml;
    "foot/foot.ini".source        = ../../dotfiles/foot/foot.ini;
    "waybar/config".source        = ../../dotfiles/waybar/config.jsonc;
    "waybar/style.css".source     = ../../dotfiles/waybar/style.css;
    "rofi/config.rasi".source     = ../../dotfiles/rofi/config.rasi;
    "niri/config.kdl".source      = ../../dotfiles/niri/config.kdl;
    "dunst/dunstrc".source        = ../../dotfiles/dunst/dunstrc;
  };

  home.file.".emacs.d/config.org".source = ../../dotfiles/emacs/config.org;
}

