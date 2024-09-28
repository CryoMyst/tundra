{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.wayvnc;
in {
  options.tundra.programs.wayvnc = {
    enable = lib.mkEnableOption "Enable wayvnc module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.homeManager = {
      home.packages = with pkgs; [
        wayvnc
      ];

      xdg.configFile.wayvnc = {
        text = ''
          use_relative_paths=true
          address=127.0.0.1
          enable_auth=false
        '';
        recursive = true;
      };
    };
  };
}
