{
  lib,
  inputs,
  ...
}: let
  inherit (inputs.nixpkgs.lib) assertMsg fix filterAttrs mergeAttrs fold recursiveUpdate callPackageWith isFunction;

  # Directories containing custom library modules
  flakeLibDirectories = [
    ./fileSystem
    ./general
    ./lists
    ./module
    ./extendedTypes
  ];

  # Namespace for custom library modules
  namespace = "tundra";

  # Utility functions for deep and shallow merges
  mergeDeep = fold recursiveUpdate {};
  mergeShallow = fold mergeAttrs {};

  # Function to extract the `lib` attribute from a set of attributes
  getLibs = attrs: let
    attrsWithLibs = filterAttrs (name: value: builtins.isAttrs (value.lib or null)) attrs;
    libs = builtins.mapAttrs (name: input: input.lib) attrsWithLibs;
  in
    libs;

  # Remove the 'self' attribute from the inputs
  withoutSelf = attrs: builtins.removeAttrs attrs ["self"];

  # Get all libraries from the inputs, excluding 'self'
  inputsLibs = getLibs (withoutSelf inputs);

  # Base library, combining Nixpkgs lib and inputs libraries
  baseLib = mergeShallow [
    inputs.nixpkgs.lib
    inputsLibs
  ];

  # Custom flake library
  flakeLib = fix (
    flakeLib: let
      attrs = {
        inherit inputs;
        lib = mergeShallow [baseLib {${namespace} = flakeLib;}];
      };
      libs =
        builtins.map (
          path: let
            importedModule = import path;
          in
            if isFunction importedModule
            then callPackageWith attrs path {}
            else importedModule
        )
        flakeLibDirectories;
    in
      mergeDeep libs
  );

  # Final library that includes the base libraries and custom flake library
  finalLib = mergeDeep [
    baseLib
    {${namespace} = flakeLib;}
  ];
in {
  flake.lib = finalLib;
}
