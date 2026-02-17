{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

  services.emacs.enable = true;

  programs.neovim = {
    enable = true;
    # package = pkgs.neovim;
    viAlias = true;
    vimAlias = true;
  };
}
