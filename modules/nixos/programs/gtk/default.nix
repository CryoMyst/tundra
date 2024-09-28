{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.gtk;
in {
  options.tundra.programs.gtk = {
    enable = lib.mkEnableOption "Enable gtk module";
  };

  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      GTK_THEME = "Adwaita:dark";
    };
    tundra.user.homeManager = {
      # Does not work, too late for WM
      # home.sessionVariables.GTK_THEME = "Adwaita:dark";

      home.packages = with pkgs; [
        adwaita-icon-theme
      ];

      gtk = {
        enable = true;
        iconTheme = {
          name = "Adwaita-dark";
          package = pkgs.adwaita-icon-theme;
        };
        theme = {
          name = "Adwaita-dark";
          package = pkgs.adwaita-icon-theme;
        };
      };
    };
  };
}
