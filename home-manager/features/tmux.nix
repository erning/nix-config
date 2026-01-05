{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.tmux;
  # Fetch Catppuccin tmux theme from GitHub
  # This provides a beautiful color scheme for tmux
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
    programs.tmux = {
      enable = true;
      # Use xterm-256color for better color support
      terminal = "xterm-256color";
      # Start window/pane indexing from 1 (0-based is default)
      baseIndex = 1;
      # Use 24-hour clock format
      clock24 = true;
      # Enable mouse support
      mouse = true;
      # Escape time in milliseconds (0 = fastest, reduces delay in vim/nvim)
      escapeTime = 0;
      # Use vi keybindings for copy/paste and pane navigation
      keyMode = "vi";

      extraConfig = ''
        # Use C-a as prefix key instead of default C-b
        unbind-key C-b
        set-option -g prefix C-a
        bind-key C-a send-prefix

        # Split windows vertically (top/bottom) with s key
        bind s split-window -v
        # Split windows horizontally (left/right) with v key
        bind v split-window -h

        # Pane navigation using h,j,k,l (vi-style) keys
        # -r means these bindings can be repeated without pressing prefix again
        bind -r h select-pane -L
        bind -r j select-pane -D
        bind -r k select-pane -U
        bind -r l select-pane -R

        # Pane resizing using Ctrl + hjkl keys
        # -r means repeatable
        bind -r C-h resize-pane -L 5
        bind -r C-j resize-pane -D 5
        bind -r C-k resize-pane -U 5

        # Enables tmux to handle extended key sequences
        # This helps with modified keys and better compatibility
        set -s extended-keys on

        #
        # Catppuccin theme configuration with CPU battery indicator
        #

        # Set color flavor (mocha, macchiato, frappe, latte)
        set -g @catppuccin_flavor "mocha"
        # Window status style (rounded, none, basic)
        set -g @catppuccin_window_status_style "rounded"
        # Date/time format in status line
        set -g @catppuccin_date_time_text ' %H:%M'

        # Source Catppuccin plugin
        run ${catppuccin-tmux}/catppuccin.tmux

        # Make status line pretty and add some modules
        # Using Catppuccin's extended status modules
        set -g status-right-length 100
        set -g status-left-length 100
        set -g status-left ""

        # Uncomment ONE of these status-right options:
        # - With application name
        # set -ag status-right "#{E:@catppuccin_status_application}"
        # - With session name
        # set -ag status-right "#{E:@catppuccin_status_session}"
        # - With date/time
        set -agF status-right "#{E:@catppuccin_status_date_time}"

        #
        # Local configuration override
        # Load user-specific config if it exists
        #

        if-shell "test -e ~/.config/tmux/tmux.local.conf" "source-file ~/.config/tmux/tmux.local.conf"
      '';
    };
  };
}
