{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.hardware.graphics;
in {
  options.tundra.hardware.graphics = {
    enable = lib.mkEnableOption "Enable graphics module";
    gpuTypes = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["nvidia" "amd"]);
      default = [];
      description = "List of GPUs to enable support for";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd.kernelModules =
      ((optionals (builtins.elem "nvidia" cfg.gpuTypes)) ["nvidia"])
      ++ ((optionals (builtins.elem "amdgpu" cfg.gpuTypes)) ["amdgpu"]);

    services.xserver.videoDrivers =
      ((optionals (builtins.elem "nvidia" cfg.gpuTypes)) ["nvidia"])
      ++ ((optionals (builtins.elem "amdgpu" cfg.gpuTypes)) ["amdgpu"]);

    hardware = {
      graphics = {
        enable = true;
        enable32Bit = true;

        extraPackages =
          (optionals (builtins.elem "amd" cfg.gpuTypes)) [pkgs.rocm-opencl-icd pkgs.rocm-opencl-runtime pkgs.amdvlk pkgs.mesa.drivers];

        extraPackages32 =
          (optionals (builtins.elem "amd" cfg.gpuTypes)) [pkgs.driversi686Linux.amdvlk];
      };
      nvidia = mkIf (builtins.elem "nvidia" cfg.gpuTypes) {
        package = pkgs.nvidiaPackages.beta;
      };
    };
  };
}
