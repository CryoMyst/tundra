# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  arch = "znver3";
in {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko.nix
  ];

  users.users.cryomyst.initialPassword = "cryomyst";
  programs.steam.enable = true;

  tundra = {
    hardware = {
      networking = {
        enable = true;
        hostName = "cryo-desktop";
      };
      audio.enable = true;
      graphics = {
        enable = true;
        gpuTypes = ["amd"];
      };
      bluetooth = {
        enable = true;
        hostname = "cryo-desktop";
      };
    };
    programs = {
      alacritty.enable = true;
    };
    services = {
      podman.enable = true;
      ssh.enable = true;
      xserver.enable = true;
    };
    system = {
      boot.enable = true;
      zfs = {
        enable = true;
        hostId = "79e57cee";
      };
      locale.enable = true;
      fonts.enable = true;
    };
    setups.sway.enable = true;
  };

  # services.xserver.enable = true;
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;
  # security.pam.services.sddm.enableGnomeKeyring = true;

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
    # printing.enable = true;
    dbus.enable = true;
    gnome.gnome-keyring.enable = true;
    gvfs.enable = true;
    udisks2.enable = true;
    devmon.enable = true;
    tumbler.enable = true;
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/persist/system".neededForBoot = true;
  system.stateVersion = "24.11";

  # From previous config
  boot.kernelParams = [
    "zswap.enabled=1"
    "amd_iommu=on"
    "mitigations=off"
    "nowatchdog"
    # "vfio-pci.ids=1002:73ff,1002:ab28"
  ];

  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
  ];

  tundra.user.homeManager = {
    wayland.windowManager.sway.config = rec {
      startup = [
        {
          command = ''
            xrandr --verbose --output "HDMI-A-1" --primary
          '';
          always = true;
        }
      ];

      keybindings = let
        # Just redefine here for now
        modifier = "Mod4";
      in
        pkgs.lib.mkOptionDefault {
          # 10th workspace for 2nd display
          "${modifier}+0" = "workspace number 10";
          "${modifier}+Shift+0" = "move container to workspace number 10";
        };

      output = {
        "HDMI-A-1" = {
          mode = "3840x2160@60.000Hz";
          pos = "0,0";
        };
        "DP-1" = {
          mode = "1920x1080@60.000Hz";
          pos = "3840,0";
          transform = "270";
          # transform = "90";
        };
      };

      workspaceOutputAssign = [
        {
          output = "HDMI-A-1";
          workspace = "1";
        }
        {
          output = "HDMI-A-1";
          workspace = "2";
        }
        {
          output = "HDMI-A-1";
          workspace = "3";
        }
        {
          output = "HDMI-A-1";
          workspace = "4";
        }
        {
          output = "HDMI-A-1";
          workspace = "5";
        }
        {
          output = "HDMI-A-1";
          workspace = "6";
        }
        {
          output = "HDMI-A-1";
          workspace = "7";
        }
        {
          output = "HDMI-A-1";
          workspace = "8";
        }
        {
          output = "HDMI-A-1";
          workspace = "9";
        }
        {
          output = "DP-1";
          workspace = "10";
        }
      ];
    };
  };
}
