{ config, lib, pkgs, ... }:

{
  ### default interactive shell
  options.myShell.default = lib.mkOption {
    type = lib.types.enum [ "fish" "zsh" "bash" ];
    default = "fish";
    description = "default shell for this host";
  };

  config = {
    programs.fish.enable = true;
    programs.zsh.enable = true;
    programs.zoxide.enable = true;
    programs.eza.enable = true;
    programs.bat.enable = true;
    programs.fzf.enable = true;
    programs.starship.enable = true;

    # shared aliases for all shells
    home.shellAliases = {
      b = "exec bash --login"; # drop into bash easily
      g = "git";
      v = "nvim";
    };

    # set the selected shell
    home.sessionVariables = {
      SHELL = pkgs.${config.myShell.default};
    };
  };
}


