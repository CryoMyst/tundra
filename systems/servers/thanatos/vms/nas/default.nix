{
  lib,
  pkgs,
  inputs,
  ...
}: {
  microvm = {
    host.enable = true;
    vms = {
      "nas" = {
        config = {
          microvm = rec {
            vcpu = 4;
            mem = 2 * 1024;
            balloonMem = (16 * 1024) - mem;

            interfaces = [
              {
                type = "bridge";
                id = "br0";
                bridge = "br0";
                mac = "dc:47:91:4c:51:e7";
              }
            ];
            shares = [
              {
                tag = "ro-store";
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
              }
            ];
            devices = [
              {
                bus = "pci";
                # LSI card
                path = "0000:05:00.0";
              }
            ];
            hypervisor = "qemu";
            writableStoreOverlay = "/nix/.rw-store";
          };

          system.stateVersion = "24.05";

          imports = [
            inputs.disko.nixosModules.default
            # ./disko.nix
          ];

          networking.hostId = "bd09613e";
          boot.supportedFilesystems = ["zfs"];
          boot.zfs.forceImportRoot = false;
          services.zfs.expandOnBoot = "disabled";
          systemd.services.zfs.enable = false;
          systemd.services.zfs-import.enable = false;

          services.openssh.enable = true;
          networking.hostName = "nas";
          networking = {
            useNetworkd = false;
            useDHCP = false;
          };
          systemd.network = {
            enable = true;
            networks = {
              "br0" = {
                matchConfig.Name = "enp*";
                address = ["10.1.30.11/24"];
                gateway = ["10.1.30.1"];
                dns = ["10.1.30.1"];
              };
            };
          };

          nix.settings.experimental-features = ["nix-command" "flakes"];
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBcDtmczDm58vyrc+DkOnu9HzgSaZR7nwOjfK7nGx1Y CryoMyst@hotmail.com"
          ];

          environment.systemPackages = with pkgs; [
            vim
            wget
            pciutils
            zfs
          ];

          # fileSystems."/export/zdata" = {
          #   device = "/pools/zdata";
          #   options = ["bind"];
          # };
          networking.firewall.allowedTCPPorts = [2049];
          services.nfs.server.enable = true;
          services.nfs.server.exports = ''
            /export       10.1.0.0/16(rw,fsid=0,no_subtree_check)
            /export/zdata 10.1.0.0/16(rw,sync,no_subtree_check,no_root_squash)
          '';
        };
      };
    };
  };
}
