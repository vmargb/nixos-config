{ config, pkgs, ... }:

{
  home-manager.users.vmargb = { pkgs, ... }: {
    programs.neovim.enable = true;

    # Recursively link everything inside modules/nvim into ~/.config/nvim
    # The 'recursive = true' is for Lazy.nvim so it can write its
    # lazy-lock.json without the parent folder being strictly read-only
    home.file.".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };
}
