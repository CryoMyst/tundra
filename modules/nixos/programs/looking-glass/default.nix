{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.looking-glass;
in {
  options.tundra.programs.looking-glass = {
    enable = lib.mkEnableOption "Enable looking-glass module";
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0666 ${config.tundra.user.name} kvm -"
    ];

    environment.systemPackages = with pkgs; [
      looking-glass-client
    ];
  };
}
