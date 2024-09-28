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

  users.users.ben.initialPassword = "ben";
  hardware.enableRedistributableFirmware = true;

  tundra = {
    hardware = {
      networking = {
        enable = true;
        hostName = "work-desktop";
      };
      audio.enable = true;
      graphics = {
        enable = true;
        gpuTypes = ["amd"];
      };
      bluetooth = {
        enable = true;
        hostname = "work-desktop";
      };
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
        hostId = "c7d9ef21";
      };
      locale.enable = true;
      fonts.enable = true;
    };
    setups.sway.enable = true;
  };

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

  system.stateVersion = "24.11";

  # From previous config
  boot.kernelParams = [
    "zswap.enabled=1"
    "nowatchdog"
  ];
}
