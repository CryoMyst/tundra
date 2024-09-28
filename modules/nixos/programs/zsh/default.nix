{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.zsh;
in {
  options.tundra.programs.zsh = with types; {
    enable = mkEnableOption "Enable custom Zsh configuration";
  };

  config = mkIf cfg.enable {
    environment.shells = [pkgs.zsh];
    programs.zsh.enable = true;
    tundra.user.extraOptions = {
      shell = pkgs.zsh;
    };

    tundra.user.homeManager = {
      home.packages = with pkgs; [
        git
        zoxide
      ];

      programs = {
        zsh = {
          enable = true;
          autosuggestion.enable = true;
          enableCompletion = true;
          enableVteIntegration = true;
          history = {ignoreAllDups = true;};
          oh-my-zsh = {
            enable = true;
            plugins = [
              "git"
              "sudo"
              "docker"
              "docker-compose"
              "dotnet"
              "gitignore"
              "man"
              "rust"
              "terraform"
              "zoxide"
            ];
            theme = "robbyrussell";
          };
          syntaxHighlighting = {enable = true;};

          shellAliases = {
          };

          plugins = [
            {
              name = "zsh-nix-shell";
              file = "nix-shell.plugin.zsh";
              src = pkgs.fetchFromGitHub {
                owner = "chisui";
                repo = "zsh-nix-shell";
                rev = "v0.7.0";
                sha256 = "149zh2rm59blr2q458a5irkfh82y3dwdich60s9670kl3cl5h2m1";
              };
            }
          ];
        };
      };
    };
  };
}
