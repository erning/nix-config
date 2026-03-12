{ config, inputs, ... }:
{
  programs.bat.enable = true;

  xdg.configFile = config.lib.dotfiles.configFiles [
    "bat/config"
  ] // {
    "bat/themes" = {
      source = "${inputs.self}/dotfiles/.config/bat/themes";
      recursive = true;
    };
  };
}
