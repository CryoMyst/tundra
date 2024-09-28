{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.services.xserver;
in {
  options.tundra.services.xserver = {
    enable = lib.mkEnableOption "Enable xserver module";
  };

  config = lib.mkIf cfg.enable {
    services = {
      xserver = {
        enable = true;
        enableTCP = true;
        exportConfiguration = true;
        logFile = "/var/log/Xorg.0.log";
      };

      libinput.enable = true;
    };

    environment.systemPackages = with pkgs; [
      xorg.xhost
      xorg.xkill
    ];
  };
}
