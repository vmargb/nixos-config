{ config, pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

  services.emacs.enable = true;

  programs.neovim = {
    enable = true;
    # if you want a particular version or fork:
    # package = pkgs.neovim;
    viAlias = true;
    vimAlias = true;
  };
}
