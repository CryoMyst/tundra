{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.direnv;
in {
  options.tundra.programs.direnv = {
    enable = lib.mkEnableOption "Enable direnv module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.homeManager = {
      programs.direnv = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
