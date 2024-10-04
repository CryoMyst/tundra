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
  hostName = "work-desktop";
in {
  imports = [
    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-zenpower
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko.nix
  ];

  users.users.ben.initialPassword = "ben";

  tundra = {
    hardware = {
      cpu.type = "amd";
      ram.total = 16;
      networking = {
        enable = true;
        inherit hostName;
      };
      audio.enable = true;
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
          "nowatchdog"
        ];
      };
      zfs = {
        enable = true;
        hostId = "c7d9ef21";
      };
      locale.enable = true;
      fonts.enable = true;
    };
    setups.sway.enable = true;
  };

  system.stateVersion = "24.11";

  tundra.user = {
    homeManager = {
      xdg.desktopEntries = {
        "Firefox - CryoMyst" = {
          name = "Firefox CryoMyst";
          exec = "firefox -p CryoMyst";
          terminal = false;
        };
        "Firefox - Icon" = {
          name = "Firefox Icon";
          exec = "firefox -p Icon";
          terminal = false;
        };
      };
    };
    packages = with pkgs; [
      azure-cli
      openvpn
      # openlens # Lens Closed its source code, package obsolete/stale - consider lens as replacement
    ];
  };

  boot.kernelModules = ["tun"];
}
