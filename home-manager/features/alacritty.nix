{ config, ... }:
{
  _description = "Alacritty terminal emulator";
  xdg.configFile = config.lib.dotfiles.configFiles [
    "alacritty/alacritty.toml"
  ];
}
