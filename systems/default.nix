{inputs, ...}: {
  imports = [
    ./desktops
    ./servers
  ];

  flake.nixosConfigurations.iso = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({
        lib,
        pkgs,
        modulesPath,
        ...
      }: let
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
        imports = [(modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")];
        environment.systemPackages = [pkgs.neovim];

        boot = {
          kernelPackages = latestZfsCompatibleLinuxPackages;
          supportedFilesystems = ["zfs"];
        };

        systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHBcDtmczDm58vyrc+DkOnu9HzgSaZR7nwOjfK7nGx1Y CryoMyst@hotmail.com"
        ];
      })
    ];
  };
}
