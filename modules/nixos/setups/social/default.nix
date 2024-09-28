{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.setups.social;
in {
  options.tundra.setups.social = {
    enable = lib.mkEnableOption "Enable social module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.packages =
      (lib.optionals true [
        pkgs.telegram-desktop
      ])
      ++ (lib.optionals (pkgs.system == "x86_64-linux") [
        pkgs.teamspeak_client
        pkgs.discord
      ]);
  };
}
