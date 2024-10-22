{
  lib,
  pkgs-stable,
  pkgs-unstable,
  pkgs-master,
  ...
}: (
  final: prev: {
    # https://github.com/NixOS/nixpkgs/pull/344608
    teamspeak_client = prev.teamspeak_client.overrideAttrs (oldAttrs: {
      pluginsdk = final.fetchurl {
        urls = [
          # "http://dl.4players.de/ts/client/pluginsdk/pluginsdk_3.1.1.1.zip"
          "https://web.archive.org/web/20180925102005/http://dl.4players.de/ts/client/pluginsdk/pluginsdk_3.1.1.1.zip"
        ];
        sha256 = "1bywmdj54glzd0kffvr27r84n4dsd0pskkbmh59mllbxvj0qwy7f";
      };
    });

    distrobox = prev.distrobox.overrideAttrs (oldAttrs: {
      postFixup =
        oldAttrs.postFixup
        + ''
          # Add additional volumes for nix and home-manager
          echo 'container_additional_volumes="/nix:/nix /etc/static/profiles/per-user:/etc/profiles/per-user:ro"' > $out/share/distrobox/distrobox.conf
          # Disable compfix for zsh for sourcing files from /nix/store
          echo 'container_manager_additional_flags="--env ZSH_DISABLE_COMPFIX=true"' >> $out/share/distrobox/distrobox.conf
          # Additional packages useful
          # zoxide is required for most shells
          # vlc gets us most audio libraries for applications
          echo 'container_additional_packages="zoxide vlc"' >> $out/share/distrobox/distrobox.conf
        '';
    });
  }
)
