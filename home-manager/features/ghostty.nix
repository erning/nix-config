{ config, ... }:
{
  _description = "Ghostty terminal emulator";
  xdg.configFile = config.lib.dotfiles.configFiles [
    "ghostty/config"
  ];
}
