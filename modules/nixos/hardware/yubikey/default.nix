{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.hardware.yubikey;
in {
  options.tundra.hardware.yubikey = {
    enable = lib.mkEnableOption "Enable yubikey module";
  };

  config = lib.mkIf cfg.enable {
    services.udev.packages = [pkgs.yubikey-personalization];

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.pcscd.enable = true;
  };
}
