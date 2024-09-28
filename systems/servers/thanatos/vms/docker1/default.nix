{
  inputs,
  pkgs,
  lib,
  ...
}: {
  microvm = {
    host.enable = true;
    vms = {
      "docker1" = {
        config = {
          microvm = rec {
            vcpu = 12;
            mem = 2 * 1024;
            balloonMem = (16 * 1024) - mem;

            interfaces = [
              {
                type = "bridge";
                id = "br0";
                bridge = "br0";
                mac = "84:de:b0:f3:64:a6";
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
              # Intel GPU
              {
                bus = "pci";
                path = "0000:0f:00.0";
              }
              {
                bus = "pci";
                path = "0000:10:00.0";
              }
            ];
            volumes = [
              {
                image = "/persist/microvms/docker1.raw";
                mountPoint = "/persist";
                size = 200 * 1024;
                autoCreate = true;
              }
            ];
            hypervisor = "qemu";
            writableStoreOverlay = "/nix/.rw-store";
          };

          imports = [
            inputs.impermanence.nixosModules.impermanence
          ];

          fileSystems."/persist".neededForBoot = true;

          system.stateVersion = "24.05";

          services.openssh.enable = true;
          networking.hostName = "docker1";
          networking = {
            useNetworkd = false;
            useDHCP = false;
          };
          systemd.network = {
            enable = true;
            networks = {
              "0-br0" = {
                matchConfig.Name = "enp*";
                address = ["10.1.30.20/24"];
                gateway = ["10.1.30.1"];
                dns = ["10.1.30.1"];
                DHCP = "no";
              };
              # "0-docker0" = {
              #   matchConfig.Name = "docker0";
              #   linkConfig = {
              #     Unmanaged = true;
              #   };
              # };
              # "0-docker-br" = {
              #   matchConfig.Name = "br-*";
              #   linkConfig = {
              #     Unmanaged = true;
              #   };
              # };
              "0-podman" = {
                matchConfig.Name = "podman*";
                linkConfig = {
                  Unmanaged = true;
                };
              };
              "0-podman-veth" = {
                matchConfig.Name = "veth*";
                linkConfig = {
                  Unmanaged = true;
                };
              };
            };
          };

          boot.initrd.kernelModules = ["i915"];
          boot.kernelParams = ["i915.force_probe=56a5"];
          boot.supportedFilesystems = ["nfs4"];
          hardware.enableRedistributableFirmware = true;
          hardware.intel-gpu-tools.enable = true;
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };
          hardware.opengl = {
            enable = true;
            extraPackages = with pkgs; [
              vpl-gpu-rt
              intel-compute-runtime
            ];
          };

          nix.settings.experimental-features = ["nix-command" "flakes"];

          security.sudo.wheelNeedsPassword = false;
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBcDtmczDm58vyrc+DkOnu9HzgSaZR7nwOjfK7nGx1Y CryoMyst@hotmail.com"
          ];

          environment.systemPackages = with pkgs; [
            vim
            wget
            podman-tui
            podman-compose
            lazydocker
          ];

          virtualisation.containers.enable = true;
          virtualisation = {
            podman = {
              enable = true;
              dockerCompat = true;
              dockerSocket.enable = true;
              defaultNetwork.settings.dns_enabled = true;
            };
          };
          # virtualisation.docker = {
          #   enable = true;
          # };

          fileSystems."/mnt/zdata" = {
            device = "10.1.30.11:/zdata";
            fsType = "nfs4";
            options = ["rw" "hard" "intr" "timeo=600" "retrans=10" "noatime" "rsize=65536" "wsize=65536"];
          };

          environment.persistence."/persist" = {
            hideMounts = true;
            directories = [
              # "/var/lib/docker"
              "/var/lib/containers"
            ];
            files = [
              "/etc/ssh/ssh_host_ed25519_key"
              "/etc/ssh/ssh_host_ed25519_key.pub"
              "/etc/ssh/ssh_host_rsa_key"
              "/etc/ssh/ssh_host_rsa_key.pub"
            ];
          };

          networking.firewall.allowedUDPPorts = [
            53 # DNS
            5353 # Multicast
          ];
          networking.firewall.allowedTCPPorts = [
            9000
          ];
          systemd.services.init-portainer-network = {
            description = "Create the portainer network";
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            serviceConfig.Type = "oneshot";
            script = ''
              # Put a true at the end to prevent getting non-zero return code, which will
              # crash the whole service.
              check=$(${lib.getExe pkgs.podman} network ls | grep "portainer" || true)
              if [ -z "$check" ]; then
                ${lib.getExe pkgs.podman} network create portainer
              else
                echo "portainer already exists in docker"
               fi
            '';
          };
          systemd.services.init-traefik-network = {
            description = "Create the traefik network";
            after = ["network.target"];
            wantedBy = ["multi-user.target"];
            serviceConfig.Type = "oneshot";
            script = ''
              # Put a true at the end to prevent getting non-zero return code, which will
              # crash the whole service.
              check=$(${lib.getExe pkgs.podman} network ls | grep "traefik" || true)
              if [ -z "$check" ]; then
                ${lib.getExe pkgs.podman} network create traefik
              else
                echo "traefik already exists in docker"
               fi
            '';
          };

          virtualisation.oci-containers.backend = "podman";
          virtualisation.oci-containers = {
            containers = {
              portainer = {
                image = "portainer/portainer-ce";
                ports = [
                  "9000:9000"
                ];
                volumes = [
                  "/var/run/docker.sock:/var/run/docker.sock"
                  # "/run/podman/podman.sock:/run/podman/podman.sock"
                  # "/var/lib/containers/storage/volumes:/var/lib/docker/volumes"
                  "portainer_data:/data"
                ];
                extraOptions = [
                  "--name=portainer"
                  "--network=portainer"
                ];
              };
            };
          };
        };
      };
    };
  };
}
