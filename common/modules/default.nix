{ config, pkgs, lib, ... }:

{
  # consistent user identity
  home.username = "vmargb";
  home.homeDirectory = "/home/vmargb";

  # packages for all hosts (appendable)
  home.packages = with pkgs; [
    fastfetch
    wl-clipboard # clipboard to terminal
    grim # screenshots
    slurp # region-based screenshots
    tree # tree hierarchy
    libnotify # media notifications (notify-send)
  ];

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
    ./mako.nix
    ./greetd.nix
    ./dotfiles.nix
    ./dev/default.nix
    ./cosmic.nix
  ];
}

