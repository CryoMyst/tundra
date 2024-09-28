{lib, ...}: {
  disko.devices = let
    mainDisk = "/dev/disk/by-id/nvme-KINGSTON_SNV2S2000G_50026B7686BDB231";

    # Make a LUKS partition with a ZFS pool inside it
    mkLuksZfsPartition = {
      cryptName,
      poolName,
    }: {
      size = "100%";
      content = {
        type = "luks";
        name = cryptName;
        extraOpenArgs = [];
        # Only used for initial setup
        passwordFile = "/tmp/disk.password";
        settings = {
          bypassWorkqueues = true;
          allowDiscards = true;
        };
        content = {
          type = "zfs";
          pool = poolName;
        };
      };
    };
    # Make a disk with a LUKS partition with a ZFS pool inside it
    mkLuksZfsDisk = {
      device,
      cryptName,
      poolName,
    }: {
      type = "disk";
      inherit device;
      content = {
        type = "gpt";
        partitions = {
          luks = mkLuksZfsPartition {
            inherit cryptName;
            inherit poolName;
          };
        };
      };
    };
    # Make a ZFS dataset
    mkZfsDataset = {
      poolName,
      datasetName,
      mountpoint,
      additionalOptions ? {},
      createBlankSnapshot ? true,
    }: {
      type = "zfs_fs";
      inherit mountpoint;
      options =
        {
          "com.sun:auto-snapshot" = "false";
          "mountpoint" = "legacy";
        }
        // additionalOptions;
      postCreateHook = lib.mkIf createBlankSnapshot ''
        zfs snapshot ${poolName}/${datasetName}@blank && zfs hold blank ${poolName}/${datasetName}@blank
      '';
    };
    mkZfsDatasetFolder = {
      poolName,
      datasetName,
      additionalOptions ? {},
      createBlankSnapshot ? true,
    }: {
      type = "zfs_fs";
      options =
        {
          "com.sun:auto-snapshot" = "false";
          "mountpoint" = "none";
          "canmount" = "off";
        }
        // additionalOptions;
      postCreateHook = lib.mkIf createBlankSnapshot ''
        zfs snapshot ${poolName}/${datasetName}@blank && zfs hold blank ${poolName}/${datasetName}@blank
      '';
    };
    # Make a ZFS pool
    mkZfsPool = {
      poolName,
      datasets ? {},
      additionalOptions ? {},
      createBlankSnapshot ? true,
    }: {
      type = "zpool";
      rootFsOptions = {
        "mountpoint" = "none";
        "canmount" = "off";
        "com.sun:auto-snapshot" = "false";
        "acltype" = "posixacl";
        "xattr" = "sa";
      };
      postCreateHook = lib.mkIf createBlankSnapshot ''
        zfs snapshot ${poolName}@blank && zfs hold blank ${poolName}@blank
      '';
      options =
        {
          ashift = "12";
        }
        // additionalOptions;
      inherit datasets;
    };
  in {
    # Define the disks
    disk = {
      system = {
        type = "disk";
        device = mainDisk;
        content = {
          type = "gpt";
          partitions = {
            esp = {
              size = "1024M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "swap";
                randomEncryption = true;
                priority = 100;
                discardPolicy = "both";
                resumeDevice = false;
              };
            };
            luks = mkLuksZfsPartition {
              cryptName = "cryptsystem";
              poolName = "zsystem";
            };
          };
        };
      };
    };

    # Create ZFS pools
    zpool = {
      zsystem = mkZfsPool {
        poolName = "zsystem";
        datasets = {
          "local" = mkZfsDatasetFolder {
            poolName = "zsystem";
            datasetName = "local";
          };
          "local/nix" = mkZfsDataset {
            poolName = "zsystem";
            datasetName = "local/nix";
            mountpoint = "/nix";
            additionalOptions = {
              "atime" = "off";
            };
          };
          "local/persist" = mkZfsDataset {
            poolName = "zsystem";
            datasetName = "local/persist";
            mountpoint = "/persist";
          };
          "local/root" = mkZfsDataset {
            poolName = "zsystem";
            datasetName = "local/root";
            mountpoint = "/";
          };
          "local/home" = mkZfsDataset {
            poolName = "zsystem";
            datasetName = "local/home";
            mountpoint = "/home";
          };
          "local/vm" = mkZfsDataset {
            poolName = "zsystem";
            datasetName = "local/vm";
            mountpoint = "/mnt/vm";
          };
        };
      };
    };
  };
}
