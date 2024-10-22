{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.setups.terminal;
in {
  options.tundra.setups.terminal = {
    enable = lib.mkEnableOption "Enable terminal module";
  };

  config = lib.mkIf cfg.enable {
    tundra.programs = {
      direnv.enable = true;
      tmux.enable = true;
      nvim.enable = true;
      zsh.enable = true;
    };

    tundra.user.packages = with pkgs; [
      git
      htop
      btop
      unzip
      p7zip
      hdparm
      wget
      jq
      lazygit
      lazydocker
      zoxide
      pciutils
      valgrind
      distrobox
      distrobox-tui
      screen
      man-pages
      man-pages-posix
      sshed
    ];
  };
}
