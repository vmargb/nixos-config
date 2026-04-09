{ config, pkgs, ... }:

{
  # Bash as default login shell, but executes 'fish'
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  programs.fish.enable = true;

  home-manager.users.vmargb = { pkgs, ... }: {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
    };

    # Zoxide (Smart cd)
    programs.zoxide = {
      enable = true;
      enableFishIntegration = true;
    };

    # Eza (Modern ls replacement)
    programs.eza = {
      enable = true;
      enableFishIntegration = true;
      icons = "auto";
      git = true;
      extraOptions = [ "--group-directories-first" "--header" ];
    };

    # FZF (Fuzzy Finder)
    programs.fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    # Fish Shell specific config
    programs.fish = {
      enable = true;

      # Aliases
      shellAliases = {
        ls = "eza";
        l = "eza -l";
        la = "eza -la";
        cd = "z";
        grep = "grep --color=auto";
        g = "git";
      };

      # run fastfetch when starting an interactive session
      interactiveShellInit = ''
        ${pkgs.fastfetch}/bin/fastfetch
      '';
    };
  };
}
