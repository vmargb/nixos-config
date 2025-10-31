{ lib }:

let
  # recursively find all .nix files under a directory
  getNixFilesRec = dir:
    let
      entries = builtins.readDir dir; # get attribute set
      names = builtins.attrNames entries; # get file name from set
    in builtins.concatMap (name:
      let
        path = dir + "/${name}";
        type = entries.${name};
      in
        if type == "directory" then
          getNixFilesRecursively path
        else if lib.hasSuffix ".nix" name && name != "default.nix" then
          [ path ]
        else
          []
    ) names;

  # (non-recursive) version
  getNixFiles = dir:
    builtins.filter # every .nix except default.nix
      (name: name != "default.nix" && lib.hasSuffix ".nix" name)
      (builtins.attrNames (builtins.readDir dir)); # get only file names

in {
  # import all .nix files in this directory
  autoImportNix = dir:
    map (name: import (dir + "/${name}"))
      (getNixFiles dir);

  # Import all .nix files recursively
  autoImportNixRec = dir:
    map import (getNixFilesRec dir);
}
