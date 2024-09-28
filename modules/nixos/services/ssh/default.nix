{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.services.ssh;
in {
  options.tundra.services.ssh = {
    enable = lib.mkEnableOption "Enable ssh module";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.startAgent = true;
    services.openssh = {
      enable = true;

      settings = {
        X11Forwarding = true;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
