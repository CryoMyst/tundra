{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.hardware.audio;
in {
  options.tundra.hardware.audio = with types; {
    enable = mkEnableOption "Enable audio support";
  };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      jack.enable = true;

      wireplumber.enable = true;
    };

    hardware.pulseaudio.enable = mkForce false;

    environment.systemPackages = with pkgs; [
      pavucontrol
    ];

    tundra.user.extraGroups = ["audio"];
  };
}
