{lib, ...}:
with lib; rec {
  fileSystem = rec {
    ## Reads directories in a directory
    ##
    ## ```nix
    ## readDirectories ./
    ## ```
    ##
    #@ path -> [path]
    readDirectories = path:
      lib.pipe path [
        builtins.readDir
        (lib.attrsets.filterAttrs (name: value: value == "directory"))
        builtins.attrNames
      ];

    ## Reads a list of nix files recursively
    ##
    ## ```nix
    ## readNixFilesRecursive ./
    ## ```
    ##
    #@ path -> [path]
    readNixFilesRecursive = path:
      lib.pipe path [
        lib.filesystem.listFilesRecursive
        (builtins.filter (name: lib.hasSuffix ".nix" name))
      ];

    # Reads a list of default nix files recursively
    ##
    ## ```nix
    ## readDefaultNixFilesRecursive ./
    ## ```
    ##
    #@ path -> [path]
    readDefaultNixFilesRecursive = path:
      lib.pipe path [
        lib.filesystem.listFilesRecursive
        (builtins.filter (name: lib.hasSuffix "default.nix" name))
      ];

    ## Makes a module from a directory recursively
    ##
    ## ```nix
    ## makeModuleFromDirectory ./
    ## ```
    ##
    #@ path -> Module
    makeModuleFromDirectory = path: ({...}: {imports = readNixFilesRecursive path;});
  };
}
