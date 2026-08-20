{ config, pkgs, ... }:

let
  catppuccin-tmux = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "tmux";
    tag = "v2.3.0";
    sha256 = "sha256-3CJRQCgS8NAN7vOLBjNGiHbGXTIrIyY/FLmfZrXcEYc=";
  };
in
{
  _description = "Omarchy-provided tmux";

  xdg.configFile = {
    # Symlink catppuccin plugin to a fixed path so dotfile can reference it
    "tmux/plugins/catppuccin".source = catppuccin-tmux;
  }
  // config.lib.dotfiles.configFilesWith {
    variant = "omarchy";
    files = [
      "tmux/tmux.conf"
      "tmux/tmux.catppuccin.conf"
      "tmux/tmux.overrides.conf"
    ];
  };
}
