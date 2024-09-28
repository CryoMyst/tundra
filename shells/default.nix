{inputs, ...}: {
  imports = [
    inputs.devshell.flakeModule
  ];

  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devshells.default = {
      packages = with pkgs; [
        nh
        git
        jq
        sops
        age
        statix
        alejandra
        deploy-rs
      ];
    };
  };
}
