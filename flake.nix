{
  description = "Tundra NixOS Configuration";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        ./parts
      ];
    };

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Virtualization
    wfvm.url = "git+https://git.m-labs.hk/m-labs/wfvm";
    nixvirt.url = "github:AshleyYakeley/NixVirt";
    microvm.url = "github:astro/microvm.nix";

    # Security & Configuration Management
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    vault-service. url = "github:DeterminateSystems/nixos-vault-service";
    disko.url = "github:nix-community/disko";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon";

    # Development Tools
    wrapper-manager.url = "github:viperML/wrapper-manager";
    devenv.url = "github:cachix/devenv";
    devshell.url = "github:numtide/devshell";
    rust-overlay.url = "github:oxalica/rust-overlay";
    nur.url = "github:nix-community/nur";
    nix-topology.url = "github:oddlama/nix-topology";
    comma.url = "github:nix-community/comma";
    compose2nix.url = "github:aksiksi/compose2nix";
    nix-ai.url = "github:nixified-ai/flake";
    nix-ld.url = "github:Mic92/nix-ld";

    # Flake Utilities
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    deploy-rs.url = "github:serokell/deploy-rs";
  };
}
