{ config, pkgs, lib, ... }:

{
  options.myDefaults.enableImports = lib.mkEnableOption "Enable standard module imports";

  config = {
    home.username = "vmargb";
    home.homeDirectory = "/home/vmargb";

    # packages for all hosts
    home.packages = with pkgs; [
      fastfetch
      wl-clipboard # clipboard to terminal
      grim # screenshots
      slurp # region-based screenshots
      tree # tree hierarchy
      libnotify # media notifications (notify-send)
    ];

    imports = lib.mkIf (config.myDefaults.enableImports or false) [
      ./shells.nix
      ./foot.nix
      ./editors.nix
      ./niri.nix
      ./waybar.nix
      ./rofi.nix
      ./mako.nix
      ./greetd.nix
      ./dotfiles.nix
      ./dev/default.nix
      ./cosmic.nix
      ./browser.nix
    ];
  };
}


