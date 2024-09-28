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
    modules = [];
    user = {
      name = "cryomyst";
      isAdmin = true;
    };
  };
}
