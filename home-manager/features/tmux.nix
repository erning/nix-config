{ pkgs, ... }:

let
  # Fetch Catppuccin tmux theme from GitHub
  # This provides a beautiful color scheme for tmux
  catppuccin-tmux = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "tmux";
    tag = "v2.3.0";
    sha256 = "sha256-3CJRQCgS8NAN7vOLBjNGiHbGXTIrIyY/FLmfZrXcEYc=";
  };
in
{
  _description = "tmux terminal multiplexer";
  programs.tmux = {
    enable = true;
    # Use tmux-256color for proper capability declaration (strikethrough, italic, RGB)
    # Preferred over xterm-256color which may misrepresent tmux's capabilities
    terminal = "tmux-256color";
    # Start window/pane indexing from 1 (0 is far from other keys on keyboard)
    baseIndex = 1;
    # Use 24-hour clock format in status bar clock (prefix + t)
    clock24 = true;
    # Enable mouse support for pane switching, window selection, and scrollback scrolling
    mouse = true;
    # Eliminate Esc key delay (default 500ms) for instant mode switching in vim/neovim
    escapeTime = 0;
    # Use vi keybindings in copy mode and command prompt
    keyMode = "vi";
    # Increase scrollback buffer from default 2000 lines; useful for long build logs
    historyLimit = 50000;

    extraConfig = ''
      # Use C-a as prefix key instead of default C-b (closer reach, screen tradition)
      unbind-key C-b
      set-option -g prefix C-a
      bind-key C-a send-prefix

      # Enable true color (RGB) passthrough for the outer terminal
      set -ag terminal-features ",xterm-256color:RGB"

      # Let vim/neovim detect focus changes (enables autoread, auto-save plugins)
      set -g focus-events on

      # Automatically renumber windows when one is closed (avoids gaps like 1,3,4)
      set -g renumber-windows on

      # Split panes: s for vertical (top/bottom), v for horizontal (left/right)
      # Mirrors vim's :split and :vsplit mnemonics
      bind s split-window -v
      bind v split-window -h

      # Pane navigation using vi-style h,j,k,l keys
      # -r allows repeating without pressing prefix again
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      # Pane resizing using Ctrl + hjkl, 5 cells per step
      # -r allows repeating for incremental adjustment
      bind -r C-h resize-pane -L 5
      bind -r C-j resize-pane -D 5
      bind -r C-k resize-pane -U 5
      bind -r C-l resize-pane -R 5

      # vi-style selection and yank in copy mode
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      # Reload config with prefix + r for quick iteration
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

      # Enable extended key sequences for better modifier key handling
      set -s extended-keys on

      #
      # Catppuccin theme configuration
      #

      # Color flavor: mocha (dark), macchiato, frappe, latte (light)
      set -g @catppuccin_flavor "mocha"
      # Window tab style: rounded, none, basic
      set -g @catppuccin_window_status_style "rounded"
      # Time format shown in status bar
      set -g @catppuccin_date_time_text ' %H:%M'

      # Load Catppuccin plugin
      run ${catppuccin-tmux}/catppuccin.tmux

      # Status bar layout
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""
      # Show session name (useful when managing multiple sessions) and time
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -agF status-right "#{E:@catppuccin_status_date_time}"

      #
      # Local configuration override
      # Load machine-specific config if it exists (not tracked in repo)
      #

      if-shell "test -e ~/.config/tmux/tmux.local.conf" "source-file ~/.config/tmux/tmux.local.conf"
    '';
  };
}
