{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.hardware.bluetooth;
in {
  options.tundra.hardware.bluetooth = with types; {
    enable = mkEnableOption "Enable bluetooth module";
    hostname = mkNullOpt str "Hostname for bluetooth";
  };

  config = mkIf cfg.enable {
    services.blueman.enable = true;
    hardware.enableAllFirmware = true;
    hardware.bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
      package = pkgs.bluez;
      settings = {
        General = {
          Name = cfg.hostname;
          ControllerMode = "dual";
          FastConnectable = "true";
          Experimental = "true";
        };
        Policy.AutoEnable = "true";
      };
    };

    environment.systemPackages = with pkgs; [
      blueman
      bluetuith
    ];
  };
}
