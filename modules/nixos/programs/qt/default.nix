{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.qt;
in {
  options.tundra.programs.qt = {
    enable = lib.mkEnableOption "Enable qt module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.homeManager = {
      home.packages = with pkgs; [
        adwaita-qt
        adwaita-qt6
        qt5.qtwayland
        qt6.qtwayland
      ];

      qt = {
        enable = true;
        platformTheme.name = "adwaita";
        style.name = "adwaita-dark";
      };
    };
  };
}
