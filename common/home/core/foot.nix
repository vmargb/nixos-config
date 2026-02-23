{ config, ... }:

{
  programs.foot = {
    enable = true;
    settings.scrollback.lines = 10000;
  };
  
  stylix.targets.foot.enable = true;
  # stylix.targets.foot.colors.override = { alpha = "0.9"; };
  # stylix.targets.foot.fonts.override = { size = 11; };
}
