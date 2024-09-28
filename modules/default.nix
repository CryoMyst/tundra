{config, ...}: let
  tundraLib = config.flake.lib.tundra;
in {
  imports = [
    ./parts
  ];

  flake.nixosModules.default = tundraLib.fileSystem.makeModuleFromDirectory ./nixos;
}
