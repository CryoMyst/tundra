{lib, ...}: {
  disko.devices = let
    dataDisks = [
      "/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX12D839PC9K"
      "/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX22D8328AX2"
      "/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX22D8328L4V"
      "/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX42D6213JVK"
      "/dev/disk/by-id/ata-WDC_WD40EFPX-68C6CN0_WD-WX82A92NKXSV"
    ];

    other = "/dev/disk/by-id/ata-ST8000DM004-2U9188_ZR11GHFR";
  in {
    disk = lib.mkMerge (lib.imap (i: disk: {
        "data-disk-${builtins.toString i}" = {
          type = "disk";
          device = disk;
          content = {
            type = "gpt";
            partitions = {
              zfs = {
                size = "100%";
                content = {
                  type = "zfs";
                  pool = "zdatapool";
                };
              };
            };
          };
        };
      })
      dataDisks);

    zpool = {
      zdatapool = {
        type = "zpool";
        mode = "raidz1";
        rootFsOptions = {
          "mountpoint" = "none";
          "canmount" = "off";
          "com.sun:auto-snapshot" = "false";
          "acltype" = "posixacl";
          "xattr" = "sa";
        };

        datasets = {
          "zdata" = {
            type = "zfs_fs";
            mountpoint = "/pools/zdata";
            options = {
              "com.sun:auto-snapshot" = "false";
              "mountpoint" = "legacy";
            };
          };
        };
      };
    };
  };
}
