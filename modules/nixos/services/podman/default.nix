{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.services.podman;
in {
  options.tundra.services.podman = {
    enable = lib.mkEnableOption "Enable podman module";
    nvidia = lib.mkEnableOption "Enable nvidia support";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.containers.enable = true;
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      enableNvidia = cfg.nvidia;
      defaultNetwork.settings.dns_enabled = true;
    };

    environment.systemPackages = with pkgs; [
      dive
      podman-tui
      lazydocker
      docker-compose
      podman-compose
    ];
  };
}
