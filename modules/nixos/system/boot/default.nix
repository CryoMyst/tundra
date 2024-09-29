{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.system.boot;
in {
  options.tundra.system.boot = with types; {
    enable = mkEnableOption "Enable boot support";
    kernelParams = {
    };
    extraKernelParams = mkOpt (listOf str) [] "Extra kernel parameters";
    kernelModules = {
      vfio = mkEnableOption "Enable VFIO kernel modules";
    };
  };

  config = mkIf cfg.enable {
    hardware.enableRedistributableFirmware = true;
    boot = {
      loader = {
        systemd-boot = {
          enable = true;
          # https://github.com/NixOS/nixpkgs/blob/c32c39d6f3b1fe6514598fa40ad2cf9ce22c3fb7/nixos/modules/system/boot/loader/systemd-boot/systemd-boot.nix#L66
          editor = false;
          configurationLimit = 20;
          consoleMode = "auto";
          memtest86.enable = true;
        };
        efi.canTouchEfiVariables = true;
      };
      tmp.cleanOnBoot = true;
      kernelParams = cfg.extraKernelParams or [];
      initrd.kernelModules =
        []
        ++ (optionals cfg.kernelModules.vfio [
          "vfio"
          "vfio_iommu_type1"
          "vfio_pci"
        ]);
    };
  };
}
