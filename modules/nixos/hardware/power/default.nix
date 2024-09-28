{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.hardware.power;
in {
  options.tundra.hardware.power = {
    enable = lib.mkEnableOption "Enable power module";
    disablePowerButton = lib.mkEnableOption "Disable power button";
  };

  config = lib.mkIf cfg.enable {
    services.logind.extraConfig =
      if cfg.disablePowerButton
      then ''
        # don’t shutdown when power button is short-pressed
        HandlePowerKey=ignore
      ''
      else '''';
  };
}
