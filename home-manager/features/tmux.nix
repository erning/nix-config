{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    terminal = "xterm-256color";
    baseIndex = 1;
    clock24 = true;
    mouse = true;
    escapeTime = 0;
    keyMode = "vi";

    extraConfig = ''
      bind s split-window -v
      bind v split-window -h

      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      bind -r C-h resize-pane -L 5
      bind -r C-j resize-pane -D 5
      bind -r C-k resize-pane -U 5
      bind -r C-l resize-pane -R 5

      if-shell "test -e ~/.config/tmux/tmux.conf.local" "source-file ~/.config/tmux/tmux.conf.local"
    '';
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.dracula;
        extraConfig = ''
          set -g @dracula-show-powerline true
          set -g @dracula-show-left-icon session
          set -g @dracula-show-timezone false
          set -g @dracula-time-format "%R"
          set -g @dracula-plugins "cpu-usage battery time"
        '';
      }
    ];
  };

}
