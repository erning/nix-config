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
  _description = "tmux terminal multiplexer";

  home.packages = [ pkgs.tmux ];

  xdg.configFile = {
    # Symlink catppuccin plugin to a fixed path so dotfile can reference it
    "tmux/plugins/catppuccin".source = catppuccin-tmux;
  } // config.lib.dotfiles.configFiles [
    # Deploy tmux.conf as editable dotfile symlink
    "tmux/tmux.conf"
  ];
}
