{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.alacritty;
in {
  options.tundra.programs.alacritty = {
    enable = lib.mkEnableOption "Enable alacritty module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.homeManager = {
      home.packages = with pkgs; [
        alacritty
      ];

      programs.alacritty = {
        enable = true;
        settings = {
          colors.primary.background = "0x000000";
        };
      };
    };
  };
}
