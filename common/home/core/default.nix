{ config, pkgs, lib, ... }:

{
  config = {
    home.username = "vmargb";
    home.homeDirectory = "/home/vmargb";

    home.packages = with pkgs; [
      fastfetch
      wl-clipboard
      grim # screenshots
      slurp # region screenshots
      tree
      libnotify # notifcation send
    ];

    imports = [
      ./dotfiles.nix
      ./editors.nix
      ./shells.nix
      ./foot.nix
      ./niri.nix
      ./rofi.nix
      ./waybar.nix
      ./greetd.nix
      ./mako.nix
    ]
  };
}
