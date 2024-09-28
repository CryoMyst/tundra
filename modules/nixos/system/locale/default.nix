{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.system.locale;
in {
  options.tundra.system.locale = {
    enable = lib.mkEnableOption "Enable locale module";
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Australia/Brisbane";
      description = "The timezone to use";
    };
    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_AU.UTF-8";
      description = "The locale to use";
    };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = cfg.timezone;
    i18n = {
      defaultLocale = cfg.locale;
      extraLocaleSettings = {
        LC_ADDRESS = cfg.locale;
        LC_IDENTIFICATION = cfg.locale;
        LC_MEASUREMENT = cfg.locale;
        LC_MONETARY = cfg.locale;
        LC_NAME = cfg.locale;
        LC_NUMERIC = cfg.locale;
        LC_PAPER = cfg.locale;
        LC_TELEPHONE = cfg.locale;
        LC_TIME = cfg.locale;
      };
    };
  };
}
