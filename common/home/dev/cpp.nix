{ config, lib, pkgs, ... }:

{
  options.dev.cpp.enable = lib.mkEnableOption "Enable C/C++ dev tools";

  config = lib.mkIf config.dev.cpp.enable {
    home.packages = with pkgs; [
      gcc gdb cmake ninja
      clang clang-tools
    ];
  };
}

