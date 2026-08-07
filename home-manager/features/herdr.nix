{ config, ... }:
{
  _description = "Herdr terminal workspace manager";

  xdg.configFile = config.lib.dotfiles.configFiles [
    "herdr/config.toml"
  ];
}
