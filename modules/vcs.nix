{ config, pkgs, ... }:

{
  programs.ssh.startAgent = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    settings.PasswordAuthentication = false;
  };

  home-manager.users.vmargb = { pkgs, ... }: {
    programs.git = {
      enable = true;
      
      userName = "vmargb";
      userEmail = "sharificles@gmail.com";

      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "vim";
      };
    };

    # SSH Client Configuration
    # TODO
    programs.ssh = {
      enable = true;
      # matchBlocks = {
      #   "github.com" = {
      #     hostname = "github.com";
      #     user = "git";
      #     identityFile = "~/.ssh/id_ed25519";
      #   };
      # };
    };
  };
}
