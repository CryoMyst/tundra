{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.tundra; let
  cfg = config.tundra.programs.tmux;
in {
  options.tundra.programs.tmux = {
    enable = lib.mkEnableOption "Enable tmux module";
  };

  config = lib.mkIf cfg.enable {
    tundra.user.homeManager = {
      programs.tmux = {
        enable = true;
        clock24 = true;
        disableConfirmationPrompt = false;
        extraConfig = ''
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R

          set -g status-position top
          set -g mouse on
        '';
        keyMode = "vi";
        mouse = false;
        newSession = false;
        plugins = with pkgs.tmuxPlugins; [
          vim-tmux-navigator
          sensible
          yank
          {
            plugin = dracula;
            extraConfig = ''
              set -g @dracula-show-battery false
              set -g @dracula-show-powerline true
              set -g @dracula-refresh-rate 10
              set -g @dracula-show-flags true
              set -g @dracula-show-left-icon session
            '';
          }
        ];
        # Overriden by shortcut
        # prefix = "C-b";
        reverseSplit = false;
        secureSocket = false;
        sensibleOnTop = true;
        shell = null;
        shortcut = "s";
        terminal = "screen";
      };
    };
  };
}
