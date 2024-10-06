{imports, ...}: {
  imports = [
    ./desktops
    ./servers
  ];

  flake.nixosConfigurations.iso = imports.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ({
        pkgs,
        modulesPath,
        ...
      }: {
        imports = [(modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")];
        environment.systemPackages = [pkgs.neovim];
      })
    ];
  };
}
