{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.thunar;
in {
  options.tundra.programs.thunar = {
    enable = lib.mkEnableOption "Enable thunar module";
  };

  config = lib.mkIf cfg.enable {
    programs.    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
    };
  };
}
