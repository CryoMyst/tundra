{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.setups.sway;
in {
  options.tundra.setups.sway = {
    enable = lib.mkEnableOption "Enable sway module";
  };

  config = lib.mkIf cfg.enable {
    tundra = {
      programs = {
        sway.enable = true;
        swaylock.enable = true;
        alacritty.enable = true;
        gtk.enable = true;
        i3status.enable = true;
        jetbrains.enable = true;
        lutris.enable = true;
        qt.enable = true;
        wayvnc.enable = true;
        wine.enable = true;
      };
      system = {
        boot.enable = true;
        locale.enable = true;
        fonts.enable = true;
      };
      hardware = {
        graphics.enable = true;
        networking.enable = true;
        audio.enable = true;
      };
      services = {
        podman.enable = true;
        ssh.enable = true;
        xserver.enable = true;
        swayidle.enable = true;
      };
      setups = {
        social.enable = true;
        terminal.enable = true;
      };
    };

    tundra.user.packages = with pkgs; [
      firefox-devedition
      obs-studio
      obsidian
      remmina
      freerdp
      file-roller
      gitkraken
      vscode
    ];

    security.pam.services.sddm.enableGnomeKeyring = true;

    programs = {
      dconf.enable = true;
      noisetorch.enable = true;
      zsh.enable = true;
      nix-ld.enable = true;
      thunar = {
        enable = true;
        plugins = with pkgs.xfce; [thunar-archive-plugin thunar-volman];
      };
    };

    services = {
      printing.enable = true;
      dbus.enable = true;
      gnome.gnome-keyring.enable = true;
      gvfs.enable = true;
      udisks2.enable = true;
      devmon.enable = true;
      tumbler.enable = true;

      greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            command = "${lib.getExe pkgs.sway}";
            user = config.tundra.user.name;
          };
          default_session = initial_session;
        };
      };
    };
  };
}
