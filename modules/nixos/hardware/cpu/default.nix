{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.hardware.cpu;
in {
  options.tundra.hardware.cpu = with types; {
    type = mkReqOpt (enum ["intel" "amd"]) "CPU type";
  };
}
