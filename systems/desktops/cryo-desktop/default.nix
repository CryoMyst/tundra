{
  inputs,
  config,
  withSystem,
  ...
}: {
  tundra.systems.cryo-desktop = {
    enable = true;
    system = "x86_64-linux";
    configuration = ./configuration.nix;
    modules = [
      inputs.nixvirt.nixosModules.default
      # inputs.nixos-vfio.nixosModules.vfio
    ];
    user = {
      name = "cryomyst";
      isAdmin = true;
    };
  };
}
