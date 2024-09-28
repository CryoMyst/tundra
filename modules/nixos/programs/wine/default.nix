{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.wine;
in {
  options.tundra.programs.wine = {
    enable = lib.mkEnableOption "Enable wine module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.packages = with pkgs; [
      winetricks
      wineWowPackages.stagingFull
    ];
  };
}
