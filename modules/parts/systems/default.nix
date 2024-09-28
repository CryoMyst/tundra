{
  inputs,
  lib,
  config,
  withSystem,
  ...
}: let
  globalConfig = config;
  cfg = config.tundra.systems;
in {
  options.tundra.systems = with lib.types;
    lib.mkOption {
      type = attrsOf (submodule
        ({
          name,
          config,
          ...
        }: {
          options = {
            enable = lib.mkOption {
              type = bool;
              default = true;
              description = "Enable the ${name} system";
            };

            system = lib.mkOption {
              type = enum ["x86_64-linux" "aarch64-linux"];
              description = "System type for the ${name} system";
            };

            configuration = lib.mkOption {
              type = path;
              default = null;
              description = "Path to the configuration file for the ${name} system";
            };

            modules = lib.mkOption {
              type = listOf unspecified;
              default = [];
              description = "Modules to include in the ${name} system";
            };

            user = {
              name = lib.mkOption {
                type = str;
                description = "Name of the ${name} user";
              };
              isAdmin = lib.mkEnableOption "Is the ${name} user an admin";
            };

            out = {
              system = lib.mkOption {
                type = unspecified;
                default = null;
                description = "Final system configuration";
              };
            };
          };

          config = lib.mkIf config.enable {
            out.system = inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit inputs;
                lib = globalConfig.flake.lib;
              };
              modules =
                [
                  # TODO: Remove
                  inputs.home-manager.nixosModules.default

                  inputs.disko.nixosModules.default
                  globalConfig.flake.nixosModules.default

                  ({...}: {
                    nixpkgs.config.allowUnfree = true;

                    nixpkgs.overlays = withSystem config.system ({overlays, ...}: overlays);
                  })

                  config.configuration

                  ({...}: {
                    tundra.user = {
                      name = config.user.name;
                      isAdmin = config.user.isAdmin;
                    };
                  })

                  ({...}: {
                    options.tundra.packages = lib.mkOption {
                      type = lib.types.attrsOf lib.types.package;
                      default = {};
                      description = "Custom packages within the flake";
                    };

                    config.tundra.packages = config.packages;
                  })
                ]
                ++ config.modules;
            };
          };
        }));
      default = {};
      description = "Systems configuration";
    };

  config = {
    flake.nixosConfigurations = lib.mapAttrs (name: system: system.out.system) cfg;
  };
}
