{pkgs, ...}: {
  wrappers.tmux = let
    configFile = pkgs.writeText "tmux.conf" ''
      run-shell ${pkgs.tmuxPlugins.sensible}/share/tmux-plugins/sensible/sensible.tmux

      set  -g default-terminal "screen"
      set  -g base-index      0
      setw -g pane-base-index 0

      set -g status-keys vi
      set -g mode-keys   vi

      # rebind main key: C-s
      unbind C-b
      set -g prefix C-s
      bind -N "Send the prefix key through to the application" s send-prefix
      bind C-s last-window

      set  -g mouse             off
      setw -g aggressive-resize off
      setw -g clock-mode-style  24
      set  -s escape-time       500
      set  -g history-limit     2000

      run-shell ${pkgs.tmuxPlugins.vim-tmux-navigator}/share/tmux-plugins/vim-tmux-navigator/vim-tmux-navigator.tmux
      run-shell ${pkgs.tmuxPlugins.yank}/share/tmux-plugins/yank/yank.tmux

      set -g @dracula-show-battery false
      set -g @dracula-show-powerline true
      set -g @dracula-refresh-rate 10
      set -g @dracula-show-flags true
      set -g @dracula-show-left-icon session

      run-shell ${pkgs.tmuxPlugins.dracula}/share/tmux-plugins/dracula/dracula.tmux

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      set -g status-position top
      set -g mouse on
    '';
  in {
    basePackage = pkgs.tmux;
    flags = [
      "-f"
      "${configFile}"
    ];
  };
}
