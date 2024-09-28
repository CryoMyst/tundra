{
  inputs,
  config,
  withSystem,
  ...
}: {
  tundra.systems.work-desktop = {
    enable = true;
    system = "x86_64-linux";
    configuration = ./configuration.nix;
    modules = [];
    user = {
      name = "ben";
      isAdmin = true;
    };
  };
}
