{ ... }:

{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "foot";
        width = 30;
        horizontal-pad = 25;
        vertical-pad = 15;
        inner-pad = 15;
        line-height = 10;
        fields = "name,generic,comment,categories,filename,keywords";
      };
      border = {
        width = 2;
        radius = 10;
      };
    };
  };
}
