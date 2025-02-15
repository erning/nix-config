{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.tmux;
  catppuccin-tmux = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "tmux";
    tag = "v2.1.2";
    sha256 = "sha256-vBYBvZrMGLpMU059a+Z4SEekWdQD0GrDqBQyqfkEHPg=";
  };
in
{
  options.features.tmux.enable = lib.mkEnableOption "tmux";

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.tmuxPlugins.cpu
      pkgs.tmuxPlugins.battery
    ];

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

        #
        # catppuccin with cpu battery
        #

        # Configure the catppuccin plugin
        set -g @catppuccin_flavor "mocha"
        set -g @catppuccin_window_status_style "rounded"
        set -g @catppuccin_date_time_text ' %H:%M'

        # Load catppuccin
        run ${catppuccin-tmux}/catppuccin.tmux

        # Make the status line pretty and add some modules
        set -g status-interval 5
        set -g status-right-length 100
        set -g status-left-length 100
        set -g status-left "#{E:@catppuccin_status_session}"
        set -g status-right "#{E:@catppuccin_status_application}"
        set -agF status-right "#{E:@catppuccin_status_cpu}"
        set -agF status-right "#{E:@catppuccin_status_battery}"
        set -agF status-right "#{E:@catppuccin_status_date_time}"

        run ${pkgs.tmuxPlugins.cpu.outPath}/share/tmux-plugins/cpu/cpu.tmux
        run ${pkgs.tmuxPlugins.battery.outPath}/share/tmux-plugins/battery/battery.tmux

        #
        # local config
        #

        if-shell "test -e ~/.config/tmux/tmux.local.conf" "source-file ~/.config/tmux/tmux.local.conf"
      '';
    };
  };
}
