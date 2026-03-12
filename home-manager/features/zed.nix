{ config, ... }:
{
  xdg.configFile = config.lib.dotfiles.configFiles [
    "zed/settings.json"
  ];
}
