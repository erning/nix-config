{ config, ... }:
{
  _description = "Omarchy-provided tmux";

  xdg.configFile = config.lib.dotfiles.configFilesWith {
    variant = "omarchy";
    files = [
      "tmux/tmux.conf"
      "tmux/tmux.overrides.conf"
    ];
  };
}
