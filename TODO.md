# TODO

## Core

- [ ] Implement Impermanence on all machines.
- [ ] Use Disko for disk management on all machines.
- [ ] Create a custom ISO installer for NixOS:
    - [ ] Enable OpenSSH and keys.
    - [ ] Install required packages.
- [ ] Better VFIO module for virtualization.
- [ ] Remove Home Manager from the flake.

## Homelab Integration

- [ ] Integrate homelab into the flake:
    - [ ] Use `microvm.nix` for Linux VMs.
    - [ ] Use `NixVirt` for Windows VMs.
    - [ ] Use `arion` for container management.
    - [ ] Use `compose2nix` for stack management.
- [ ] Implement Sops for secret management:
    - [ ] Master secret.
    - [ ] Machine-specific secrets.
    - [ ] Deploy script to read from the persistent directory and SCP secrets to the machines.
    - [ ] Generate `.sops.yaml` to restrict each machine's access to only its necessary secrets.
        ```shell
        nix eval --impure --json .\#nixosConfigurations --apply \
        "x : (let lib = import <nixpkgs/lib>; in (builtins.mapAttrs \
        (nname: nvalue: (lib.mapAttrsToList (nsecret: vsecret: vsecret.sopsFile) \
        nvalue.config.sops.secrets)) x))"
        ```
## Development Environment

- [ ] Ensure dev packages are self-contained for use on remote machines.
- [ ] Create "Dev" zsh setup for remote machines.
- [ ] Create a script to download and run a Nix portable binary.

## Observability and Monitoring

- [ ] Set up observability and monitoring via Prometheus and Grafana.

## Documentation

- [ ] Create a comprehensive README for the repository.
