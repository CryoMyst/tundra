{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.system.zfs;

  latestZfsCompatibleLinuxPackages = lib.pipe pkgs.linuxKernel.packages [
    builtins.attrValues
    (builtins.filter (
      kPkgs:
        (builtins.tryEval kPkgs).success
        && kPkgs ? kernel
        && kPkgs.kernel.pname == "linux"
        && !kPkgs.zfs.meta.broken
    ))
    (builtins.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)))
    lib.last
  ];
in {
  options.tundra.system.zfs = with types; {
    enable = mkEnableOption "Enable ZFS support";
    hostId = mkNullOpt str "The host ID for the system";
    rollbackOnBoot = mkOpt (listOf str) [] "Rollback these ZFS snapshots @blank on boot";
  };

  config = mkIf cfg.enable {
    boot = {
      kernelPackages = latestZfsCompatibleLinuxPackages;
      supportedFilesystems = ["zfs"];
    };
    networking.hostId = cfg.hostId;
    services.zfs.autoScrub.enable = true;
    services.zfs.autoSnapshot.enable = true;

    boot.initrd.systemd.services =
      map (rollbackOnBoot: {
        name = "zfs-rollback-${replaceChars ["/" "."] ["-" "-"] rollbackOnBoot}";
        wantedBy = ["initrd.target"];
        after = ["zfs-import.target"];
        before = ["sysroot.mount"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${getExe pkgs.zfs} rollback -r ${rollbackOnBoot}@blank";
        };
      })
      cfg.rollbackOnBoot;
  };
}
