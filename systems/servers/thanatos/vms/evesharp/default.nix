{
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (inputs) nixvirt;
in {
  virtualisation.libvirt.connections."qemu:///system" = {
    domains = [
      {
        definition = nixvirt.lib.domain.writeXML (nixvirt.lib.domain.templates.windows
          {
            name = "EveSharp";
            uuid = "def734bb-e2ca-44ee-80f5-0ea0f2593aaa";
            memory = {
              count = 16;
              unit = "GiB";
            };
            storage_vol = {
              pool = "ImagePool";
              volume = "EveSharp.qcow2";
            };
            install_vol = /persist/libvirt/isos/Win11_23H2_English_x64v2.iso;
            nvram_path = /persist/libvirt/ram/EveSharp.nvram;
            virtio_net = true;
            virtio_drive = true;
            virtio_video = false;
            install_virtio = true;
          }
          // {
            vcpu = {
              placement = "static";
              count = 12;
            };
            cpu = {
              mode = "host-passthrough";
              topology = {
                sockets = 1;
                dies = 1;
                cores = 6;
                threads = 2;
              };
              feature = [
                {
                  policy = "require";
                  name = "topoext";
                }
                {
                  policy = "require";
                  name = "avic";
                }
              ];
              cache = {
                mode = "passthrough";
              };
            };
            iothreads = {
              count = 1;
            };
            cputune = {
              vcpupin = [
                {
                  vcpu = 0;
                  cpuset = "0";
                }
                {
                  vcpu = 1;
                  cpuset = "1";
                }
                {
                  vcpu = 2;
                  cpuset = "2";
                }
                {
                  vcpu = 3;
                  cpuset = "3";
                }
                {
                  vcpu = 4;
                  cpuset = "4";
                }
                {
                  vcpu = 5;
                  cpuset = "5";
                }
                {
                  vcpu = 6;
                  cpuset = "12";
                }
                {
                  vcpu = 7;
                  cpuset = "13";
                }
                {
                  vcpu = 8;
                  cpuset = "14";
                }
                {
                  vcpu = 9;
                  cpuset = "15";
                }
                {
                  vcpu = 10;
                  cpuset = "16";
                }
                {
                  vcpu = 11;
                  cpuset = "17";
                }
              ];
              emulatorpin = {cpuset = "6";};
              iothreadpin = {
                iothread = 1;
                cpuset = "6";
              };
            };
            memoryBacking = {
              hugepages = {};
            };
          });
      }
    ];
    networks = [
    ];
    pools = [
      {
        active = true;
        definition = nixvirt.lib.pool.writeXML {
          name = "ImagePool";
          uuid = "650c5bbb-eebd-4cea-8a2f-36e1a75a8683";
          type = "dir";
          target = {path = "/persist/libvirt/images";};
        };
      }
      {
        active = true;
        definition = nixvirt.lib.pool.writeXML {
          name = "IsoPool";
          uuid = "650c5bbb-eebd-4cea-8a2f-36e1a75a8684";
          type = "dir";
          target = {path = "/persist/libvirt/isos";};
        };
      }
      {
        active = true;
        definition = nixvirt.lib.pool.writeXML {
          name = "RamPool";
          uuid = "650c5bbb-eebd-4cea-8a2f-36e1a75a8685";
          type = "dir";
          target = {path = "/persist/libvirt/ram";};
        };
      }
    ];
  };
}
