{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.i3status;
in {
  options.tundra.programs.i3status = {
    enable = lib.mkEnableOption "Enable i3status module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.homeManager = {
      home.packages = with pkgs; [
        i3status
      ];
      programs.i3status = {
        enable = true;
        enableDefault = false;

        general = {
          colors = true;
          interval = 5;
        };

        modules = {
          "disk /" = {
            position = 1;
            settings = {format = "%avail";};
          };

          "load" = {
            position = 2;
            settings = {format = "%1min";};
          };

          "memory" = {
            position = 3;
            settings = {
              format = "%used/%available";
              threshold_degraded = "1G";
              format_degraded = "MEMORY < %available";
            };
          };

          "tztime local" = {
            position = 100;
            settings = {format = "%Y-%m-%d %H:%M:%S";};
          };
        };
      };
    };
  };
}
