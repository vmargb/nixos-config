{ config, lib, pkgs, ... }:

{
  options.dev.general.enable = lib.mkEnableOption "Enable general dev tools";

  config = lib.mkIf config.dev.general.enable {
    home.packages = with pkgs; [
    ];
  };

  imports = [
    ./langs/python.nix
    ./langs/cpp.nix
    ./langs/android.nix
    ./langs/rust.nix
    ./langs/node.nix
    ./langs/go.nix
  ]
  # secrets are optional: imported only if present
  ++ lib.optionals (builtins.pathExists ../../secrets/git.nix) [ ../../secrets/git.nix ]
  ++ lib.optionals (builtins.pathExists ../../secrets/ssh.nix) [ ../../secrets/ssh.nix ];
}


