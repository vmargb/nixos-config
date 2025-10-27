{ config, lib, pkgs, ... }:

{
  ### option to select default shell
  options.myShell.default = lib.mkOption {
    type = lib.types.enum [ "fish" "zsh" "bash" ];
    default = "fish";
    description = "Default shell for this host.";
  };

  config = {
    programs.fish.enable = true;
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
    };

    ## common CLI utilities
    programs.zoxide.enable = true;
    programs.eza.enable = true;
    programs.bat.enable = true;
    programs.fzf.enable = true;
    programs.starship.enable = true;

    ## shared aliases
    home.shellAliases = {
      b = "exec bash --login";
      g = "git";
      v = "nvim";
      ls = "eza --icons";
      cat = "bat";
      grep = "rg";
      f = "fzf";
    };

    ## shared environment variables
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SHELL = "${pkgs.${config.myShell.default}}/bin/${config.myShell.default}";
    };

    ## add ~/.local/bin to PATH for all shells and GUI apps
    home.sessionPath = [ "$HOME/.local/bin" ];

    ## Starship configuration
    home.file.".config/starship.toml".text = ''
      # starship prompt
      add_newline = true

      [character]
      success_symbol = "[❯](bold green)"
      error_symbol = "[❯](bold red)"

      [package]
      disabled = true

      [directory]
      truncation_length = 3

      [git_branch]
      symbol = "🌱 "

      [git_status]
      disabled = false
    '';

    ## Fish configuration
    home.file.".config/fish/config.fish".text = ''
      zoxide init fish | source
      starship init fish | source
    '';

    ## Zsh configuration
    home.file.".zshrc".text = ''
      eval "$(zoxide init zsh)"
      eval "$(starship init zsh)"
    '';

    ## Bash configuration
    home.file.".bashrc".text = ''
      eval "$(zoxide init bash)"
      eval "$(starship init bash)"
    '';
  };
}
