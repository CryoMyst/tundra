{
  inputs,
  config,
  withSystem,
  ...
}: {
  tundra.systems.thanatos = {
    enable = true;
    system = "x86_64-linux";
    configuration = ./configuration.nix;
    modules = [
      inputs.nixvirt.nixosModules.default
      inputs.impermanence.nixosModules.impermanence
      inputs.microvm.nixosModules.host
    ];
    users.homelab = {
      enable = true;
      isAdmin = true;
    };
  };

  flake.deploy.nodes.thanatos = {
    hostname = "10.1.30.10";
    profiles.system = {
      user = "root";
      sshUser = "homelab";
      path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos inputs.self.nixosConfigurations.thanatos;
      remoteBuild = true;
      autoRollback = true;
      magicRollback = true;

      activationTimeout = 600;
      confirmTimeout = 120;
    };
  };
}
