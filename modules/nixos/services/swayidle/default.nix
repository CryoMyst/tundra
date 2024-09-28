{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.services.swayidle;
in {
  options.tundra.services.swayidle = {
    enable = lib.mkEnableOption "Enable swayidle module";
    lockTimeout = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = "The time in seconds before the screen locks";
    };
    lockCommand = lib.mkOption {
      type = lib.types.str;
      default = "${pkgs.swaylock}/bin/swaylock -f";
      description = "The command to run when locking the screen";
    };
  };

  config = lib.mkIf cfg.enable {
    tundra.user.packages = with pkgs; [
      swayidle
    ];

    tundra.user.homeManager = {
      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = cfg.lockTimeout;
            command = cfg.lockCommand;
          }
        ];
      };
    };
  };
}
