{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  baseDir = "/mnt/vm";
  nixvirt = inputs.nixvirt;
in {
  # https://github.com/j-brn/nixos-vfio
  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      clearEmulationCapabilities = false;
      qemu = {
        runAsRoot = true;
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
      };
      deviceACL = [
        "/dev/null"
        "/dev/full"
        "/dev/zero"
        "/dev/random"
        "/dev/urandom"
        "/dev/ptmx"
        "/dev/kvm"
        "/dev/kqemu"
        "/dev/rtc"
        "/dev/hpet"
        "/dev/net/tun"
      ];
    };
    libvirt = {
      enable = true;
      swtpm.enable = true;
    };
    # kvmfr = {
    #   enable = true;

    #   devices = [
    #     {
    #       size = 256;
    #       permissions = {
    #         user = config.tundra.user.name;
    #       };
    #     }
    #   ];
    # };
  };

  virtualisation.libvirtd.hooks.qemu = {
    "cpu-isolate" = lib.getExe (
      pkgs.writeShellApplication {
        name = "qemu-hook";

        runtimeInputs = [
          pkgs.systemd
        ];

        text = ''
          #!/bin/sh

          command=$2

          if [ "$command" = "started" ]; then
            systemctl set-property --runtime -- system.slice AllowedCPUs=0-7,16-23
            systemctl set-property --runtime -- user.slice AllowedCPUs=0-7,16-23
            systemctl set-property --runtime -- init.scope AllowedCPUs=0-7,16-23
          elif [ "$command" = "release" ]; then
            systemctl set-property --runtime -- system.slice AllowedCPUs=0-31
            systemctl set-property --runtime -- user.slice AllowedCPUs=0-31
            systemctl set-property --runtime -- init.scope AllowedCPUs=0-31
          fi
        '';
      }
    );
  };

  users.groups.libvirtd.members = ["root" config.tundra.user.name];
  users.groups.kvm.members = ["root" config.tundra.user.name];
  programs.dconf.enable = true;
  programs.virt-manager.enable = true;
  services.spice-vdagentd.enable = true;
  #   services.dnsmasq.enable = false;

  boot.kernel.sysctl = {
    "vm.nr_hugepages" = 0;
    "vm.nr_overcommit_hugepages" = 32;
  };
  tundra.system.boot.extraKernelParams = [
    "default_hugepagesz=1G"
    "hugepagesz=1G"
    "transparent_hugepage=never"
    "kvm.ignore-msrs=1"
    # "kvmfr.static_size_mb=256"
  ];
  boot.initrd.kernelModules = [
    "vfio_pci"
    "vfio"
    "vfio_iommu_type1"
    # "kvmfr"

    # "i2c_dev"
    # "ddcci_backlight"
  ];

  virtualisation.libvirt.connections."qemu:///system" = {
    domains = [
      {
        active = false;
        definition = ./windows.xml;
      }
    ];
    pools = [
      {
        active = true;
        definition = nixvirt.lib.pool.writeXML {
          name = "ImagePool";
          uuid = "650c5bbb-eebd-4cea-8a2f-36e1a75a8683";
          type = "dir";
          target = {path = baseDir + "/images";};
        };
      }
      {
        active = true;
        definition = nixvirt.lib.pool.writeXML {
          name = "IsoPool";
          uuid = "650c5bbb-eebd-4cea-8a2f-36e1a75a8684";
          type = "dir";
          target = {path = baseDir + "/isos";};
        };
      }
      {
        active = true;
        definition = nixvirt.lib.pool.writeXML {
          name = "RamPool";
          uuid = "650c5bbb-eebd-4cea-8a2f-36e1a75a8685";
          type = "dir";
          target = {path = baseDir + "/ram";};
        };
      }
    ];
    networks = [
    ];
  };
}
