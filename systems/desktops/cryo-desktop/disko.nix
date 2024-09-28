{lib, ...}: {
  disko.devices = let
    systemDisk = "/dev/disk/by-id/nvme-Sabrent_Rocket_4.0_1TB_CD8E0706019E03599744";
    userDisk = "/dev/disk/by-id/nvme-Sabrent_Rocket_4.0_1TB_BED20717016600133070";
    vmDisk = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S69ENF0WB47116K";
    ssd1Disk = "/dev/disk/by-id/ata-CT1000BX500SSD1_2410E89D6A3D";
    hdd1Disk = "/dev/disk/by-id/ata-WDC_WD20EZAZ-00GGJB0_WD-WXL2A30ETDRK";

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
        device = systemDisk;
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
      user = mkLuksZfsDisk {
        device = userDisk;
        cryptName = "cryptuser";
        poolName = "zuser";
      };
      vm = mkLuksZfsDisk {
        device = vmDisk;
        cryptName = "cryptvm";
        poolName = "zvm";
      };
      ssd1 = mkLuksZfsDisk {
        device = ssd1Disk;
        cryptName = "cryptssd1";
        poolName = "zssd1";
      };
      hdd1 = mkLuksZfsDisk {
        device = hdd1Disk;
        cryptName = "crypthdd1";
        poolName = "zhdd1";
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
          "local/syspersist" = mkZfsDataset {
            poolName = "zsystem";
            datasetName = "local/syspersist";
            mountpoint = "/persist/system";
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
        };
      };
      zuser = mkZfsPool {
        poolName = "zuser";
        datasets = {
          "local" = mkZfsDatasetFolder {
            poolName = "zuser";
            datasetName = "local";
          };
          "local/persist" = mkZfsDataset {
            poolName = "zuser";
            datasetName = "local/persist";
            mountpoint = "/persist";
          };
        };
      };
      zvm = mkZfsPool {
        poolName = "zvm";
        datasets = {
          "local" = mkZfsDatasetFolder {
            poolName = "zvm";
            datasetName = "local";
          };
          "local/vm" = mkZfsDataset {
            poolName = "zvm";
            datasetName = "local/vm";
            mountpoint = "/mnt/vm";
          };
        };
      };
      zssd1 = mkZfsPool {
        poolName = "zssd1";
        datasets = {
          "local" = mkZfsDatasetFolder {
            poolName = "zssd1";
            datasetName = "local";
          };
          "local/data" = mkZfsDataset {
            poolName = "zssd1";
            datasetName = "local/data";
            mountpoint = "/mnt/ssd1";
          };
        };
      };
      zhdd1 = mkZfsPool {
        poolName = "zhdd1";
        datasets = {
          "local" = mkZfsDatasetFolder {
            poolName = "zhdd1";
            datasetName = "local";
          };
          "local/data" = mkZfsDataset {
            poolName = "zhdd1";
            datasetName = "local/data";
            mountpoint = "/mnt/hdd1";
          };
        };
      };
    };
  };
}
