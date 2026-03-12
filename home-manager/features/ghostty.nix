{ config, ... }:
{
  xdg.configFile = config.lib.dotfiles.configFiles [
    "ghostty/config"
  ];
}
