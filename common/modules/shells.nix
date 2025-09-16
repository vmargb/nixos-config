{ pkgs, ... }:
{
  programs.fish.enable = true;
  programs.zoxide.enable = true;
  programs.eza.enable = true;
  programs.fzf.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };
}

