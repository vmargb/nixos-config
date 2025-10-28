{ config, lib, pkgs, ... }:

{
  options.dev.android.enable = lib.mkEnableOption "Enable Android/Kotlin dev tools";

  config = lib.mkIf config.dev.android.enable {
    home.packages = with pkgs; [
      jdk17 gradle kotlin android-tools
      (androidenv.androidPkgs.sdk "commandlinetools;latest")
      (androidenv.androidPkgs.sdk "platform-tools")
      (androidenv.androidPkgs.sdk "platforms;android-34")
      (androidenv.androidPkgs.sdk "build-tools;34.0.0")
    ];
  };
}

