{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.hardware.networking;
in {
  options.tundra.hardware.networking = with types; {
    enable = mkEnableOption "Enable networking support";
    hostName = mkNullOpt str "The host name for the system";
    hosts = mkOpt (attrsOf (listOf str)) {} "The hosts file entries";
  };

  config = mkIf cfg.enable {
    tundra.user.extraGroups = ["networkmanager"];

    networking = {
      hosts =
        {
          "127.0.0.1" = ["local.test"] ++ (cfg.hosts."127.0.0.1" or []);
        }
        // cfg.hosts;

      inherit (cfg) hostName;

      networkmanager = {
        enable = true;
        # dhcp = "internal";
      };
    };

    networking.firewall.enable = true;
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
