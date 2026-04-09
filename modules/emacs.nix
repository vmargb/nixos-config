{ config, pkgs, ... }:

{
  home-manager.users.vmargb = { pkgs, ... }: {
    programs.emacs.enable = true;

    # symlink specific files rather than the whole directory so that Emacs
    # can still write temporary files or packages into ~/.config/emacs without error
    home.file.".config/emacs/init.el".source = ./emacs/init.el;
    home.file.".config/emacs/early-init.el".source = ./emacs/early-init.el;
    home.file.".config/emacs/banner.txt".source = ./emacs/banner.txt;
  };
}
