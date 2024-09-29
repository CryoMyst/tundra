{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.system.impermanence;

  impermanenceOptions = types.submodule ({name, ...}:
    with types; {
      options = {
        path = mkReqOpt str "Path to the persistent directory";
        enable = mkOpt bool true "Enable impermanence for this type";
        system = {
          directories = mkOpt (listOf str) [] "Directories to keep";
          files = mkOpt (listOf str) [] "Files to keep";
        };
        user = {
          directories = mkOpt (listOf str) [] "Directories to keep";
          files = mkOpt (listOf str) [] "Files to keep";
        };
      };
    });
in {
  options.tundra.system.impermanence = {
    enable = mkEnableOption "Enable impermanence module";
    # Critial directories and files we do not want to lose
    critical = mkOpt impermanenceOptions {} "Critial impermanence options";
    # Volatile directories like caches or temporary files which can be easily recreated
    volatile = mkOpt impermanenceOptions {} "Volatile impermanence options";
  };

  config = lib.mkIf cfg.enable {
    environment.persistence = let
      impermanenceCfgs = [
        cfg.critical
        cfg.volatile
      ];
      enabledCfgs = lib.filter (cfg: cfg.enable) impermanenceCfgs;
      transformedCfgs =
        lib.map (cfg: {
          "${cfg.path}" = {
            directories = cfg.system.directories;
            files = cfg.system.files;
            users."${config.tundra.user.name}" = {
              directories = cfg.user.directories;
              files = cfg.user.files;
            };
          };
        })
        enabledCfgs;
    in
      mkMerge transformedCfgs;
  };
}
