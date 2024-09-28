{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.lutris;
in {
  options.tundra.programs.lutris = {
    enable = lib.mkEnableOption "Enable lutris module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.packages = with pkgs; [
      (lutris.override {
        extraPkgs = pkgs: [
          winetricks
          wineWowPackages.staging
          libnghttp2
          jansson
        ];
      })
    ];
  };
}
