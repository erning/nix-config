{ config, ... }:
{
  _description = "Zed editor";
  xdg.configFile = config.lib.dotfiles.configFiles [
    "zed/settings.json"
  ];
}
