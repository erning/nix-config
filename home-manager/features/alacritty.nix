{ config, ... }:
{
  xdg.configFile = config.lib.dotfiles.configFiles [
    "alacritty/alacritty.toml"
  ];
}
