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
  hostName = "cryo-desktop";
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

  tundra = {
    hardware = {
      cpu.type = "amd";
      ram.total = 128;
      audio.enable = true;
      networking = {
        enable = true;
        inherit hostName;
      };
      graphics = {
        enable = true;
        gpuTypes = ["amd"];
      };
      bluetooth = {
        enable = true;
        inherit hostName;
      };
    };
    programs = {
      thunar.enable = true;
      alacritty.enable = true;
    };
    services = {
      podman.enable = true;
      ssh.enable = true;
      xserver.enable = true;
    };
    system = {
      boot = {
        enable = true;
        extraKernelParams = [
          "zswap.enabled=1"
          "amd_iommu=on"
          "mitigations=off"
          "nowatchdog"
          # "vfio-pci.ids=1002:73ff,1002:ab28"
        ];
        kernelModules = {
          vfio = true;
        };
      };
      zfs = {
        enable = true;
        hostId = "79e57cee";
      };
      locale.enable = true;
      fonts.enable = true;
      impermanence = {
        # enable = true;
        critical.path = "/persist";
        volatile.path = "/persist/system";
      };
    };
    setups.sway.enable = true;
  };

  programs = {
    noisetorch.enable = true;
    nix-ld.enable = true;
    steam.enable = true;
  };

  fileSystems."/persist".neededForBoot = true;
  fileSystems."/persist/system".neededForBoot = true;
  system.stateVersion = "24.11";

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
        modifier = config.tundra.programs.sway.modifier;
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
