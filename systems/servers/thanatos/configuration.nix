{
  config,
  lib,
  pkgs,
  nixvirt,
  microvm,
  disko,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disko.nix
    ./networking.nix

    # MicroVMs
    ./vms/docker1
    ./vms/nas

    # Libvirt VMs
    # ./vms/evesharp
  ];

  fileSystems."/persist" = {
    neededForBoot = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  system.stateVersion = "24.05";

  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "694f9e29";

  networking.hostName = "thanatos";
  time.timeZone = "Australia/Brisbane";
  security.sudo.wheelNeedsPassword = false;
  users.users.homelab = {
    isNormalUser = true;
    initialPassword = "homelab";
    extraGroups = ["wheel" "libvirtd" "docker" "kvm"];
    packages = with pkgs; [
      firefox
      tree
      nano
      sudo
      rsync
      git
      ethtool
      btop
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBcDtmczDm58vyrc+DkOnu9HzgSaZR7nwOjfK7nGx1Y CryoMyst@hotmail.com"
    ];
  };

  environment.persistence = {
    "/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/docker"
        "/var/lib/microvms"
      ];
      users.homelab = {
        directories = [
          "Projects"
        ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  # Enable nix flake support
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = ["nix-command" "flakes"];

      substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
    };
  };

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = true;

  programs.virt-manager.enable = true;
  programs.dconf.enable = true;
  services.spice-vdagentd.enable = true;

  virtualisation = {
    spiceUSBRedirection.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf = {
          enable = true;
          packages = [pkgs.OVMFFull.fd];
        };
      };
      allowedBridges = ["br0"];
    };
    libvirt = {
      enable = true;
      swtpm.enable = true;
    };
  };

  boot = {
    initrd.kernelModules = [
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];
    kernelParams = let
      LsiCard = ["1000:0072"];
      amdGpu = ["1002:73ff" "1002:ab28"];
      # amdGpu = [];
      intelGpu = ["8086:56a5" "8086:4f92"];

      pcieIdParameter = builtins.concatStringsSep "," (LsiCard ++ amdGpu ++ intelGpu);
    in [
      "zfs.zfs_arc_max=${toString (1024 * 1024 * 1024 * 10)}"
      "pcie_acs_override=downstream,multifunction"
      "amd_iommu=on"
      "vfio-pci.ids=${pcieIdParameter}"
    ];
  };
  boot.loader.systemd-boot.memtest86.enable = true;
  boot.kernelPatches = [
    {
      name = "add-acs-overrides";
      patch = pkgs.fetchurl {
        name = "add-acs-overrides.patch";
        url = "https://raw.githubusercontent.com/benbaker76/linux-acs-override/main/6.3/acso.patch";
        sha256 = "sha256-bsi4UIasDn3ErP7MH8ooi4+DOY1AvptqHJ4fzt8ejvQ=";
      };
    }
  ];
}
