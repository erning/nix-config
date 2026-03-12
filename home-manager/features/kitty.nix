{ config, ... }:
{
  xdg.configFile = config.lib.dotfiles.configFiles [
    "kitty/kitty.conf"
    "kitty/kitty.app.png"
    "kitty/current-theme.conf"
  ];
}
