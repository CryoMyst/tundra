{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.swaylock;
in {
  options.tundra.programs.swaylock = {
    enable = lib.mkEnableOption "Enable swaylock module";
  };

  config = lib.mkIf cfg.enable {
    security.pam.services.sddm.enableGnomeKeyring = true;
    security.pam.services.swaylock.text = ''
      auth include login
    '';

    tundra.user.packages = with pkgs; [
      swaylock
    ];

    tundra.user.homeManager = {
      programs.swaylock = {
        enable = true;
        settings = {
          color = "#000000";
          show-failed-attempts = true;
        };
      };
    };
  };
}
