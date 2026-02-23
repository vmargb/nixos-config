{ config, pkgs, ... }:

{
  imports = [
    ../../common/home/core
  ];

  home.packages = with pkgs; [
  ];
}
