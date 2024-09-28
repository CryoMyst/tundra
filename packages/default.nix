{
  lib,
  config,
  inputs,
  withSystem,
  ...
}: let
  tundraLib = config.flake.lib.tundra;
in {
  perSystem = {
    pkgs,
    system,
    inputs',
    ...
  }: let
    mkNixPkgs = nixpkgs:
      import nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
        };
      };

    pkgs-stable = mkNixPkgs inputs.nixpkgs-stable;
    pkgs-unstable = mkNixPkgs inputs.nixpkgs-unstable;
    pkgs-master = mkNixPkgs inputs.nixpkgs-master;

    overlays = lib.fix (
      self: let
        callPackage = lib.callPackageWith {
          inherit inputs';
          inherit system;
          inherit (config.flake) lib;
          inherit pkgs;
          inherit pkgs-stable;
          inherit pkgs-unstable;
          inherit pkgs-master;
        };

        calledOverlays = lib.pipe ./overlays [
          tundraLib.fileSystem.readDefaultNixFilesRecursive
          (lib.map (overlayFile: callPackage overlayFile {}))
        ];
      in
        calledOverlays
    );

    pkgs-default = import inputs.nixpkgs {
      inherit system;
      inherit overlays;

      config = {
        allowUnfree = true;
      };
    };
    pkgs = pkgs-default;
  in {
    _module.args.pkgs = pkgs-default;
    _module.args.overlays = overlays;

    packages = lib.fix (self: let
      # Packaged within the flake inside ./packaged
      stage1 = lib.fix (self': let
        callPackage = lib.callPackageWith {
          pkgs = pkgs // self';
        };

        packaged = lib.pipe (builtins.readDir ./packaged) [
          (lib.filterAttrs (name: value: value == "directory"))
          (builtins.mapAttrs (name: _: callPackage ./packaged/${name} {}))
        ];
      in
        packaged);

      # Wrapped packages using wrapper-manager
      # (This is not all wrapped packages, only those that have a global config)
      stage2 =
        lib.recursiveUpdate stage1
        (inputs.wrapper-manager.lib {
          pkgs = pkgs // stage1;
          modules = lib.pipe (builtins.readDir ./wrapped) [
            (lib.filterAttrs (name: value: value == "directory"))
            builtins.attrNames
            (map (n: ./wrapped/${n}))
          ];
          specialArgs = {
            inherit inputs';
          };
        })
        .config
        .build
        .packages;

      # Packages that depend on wrapped packages
      # Mainly development environments that consist of multiple packages
      stage3 = let
        callPackage = lib.callPackageWith {
          pkgs = pkgs // stage2;
        };

        envs = lib.pipe (builtins.readDir ./envs) [
          (lib.filterAttrs (name: value: value == "directory"))
          (builtins.mapAttrs (name: _: callPackage ./envs/${name} {}))
        ];
      in
        stage2 // envs;

      final = stage3;
    in
      final);
  };
}
