{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.hardware.ram;
in {
  options.tundra.hardware.ram = with types; {
    total = mkReqOpt int "Total RAM in GB";
  };
}
