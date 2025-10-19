{ config, lib, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-config/dotfiles";

  # helper function to get full path to each dotfile
  linkDir = path: {
    source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
    recursive = true;
  };

  # retrieve every subdirectory in dotfiles/
  dirs = builtins.attrNames (builtins.readDir dotfiles);

  # takes dirs from above, and pass it into linkDir
  # to create a mkOutOfStoreSymlink for every directory automatically
  configDirs =
    builtins.listToAttrs (map (name: {
      name = name; # becomes ~/.config/${name}
      value = linkDir name;
    }) dirs);

in {
  xdg.configFile = configDirs; # symlink everything inside dotfiles/ into ~/.config/{subdir}
}

