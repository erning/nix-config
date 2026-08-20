{ config, ... }:
{
  _description = "Omarchy-provided tmux";

  xdg.configFile = config.lib.dotfiles.configFiles {
    variant = "omarchy";
    files = [
      "tmux/tmux.conf"
      "tmux/tmux.overrides.conf"
    ];
  };
}
