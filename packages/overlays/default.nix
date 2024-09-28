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
  }
)
