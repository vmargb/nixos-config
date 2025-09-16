{ config, pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;
  };

  services.emacs.enable = true;
}

