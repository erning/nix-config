{ config, ... }:
{
  _description = "Omarchy-integrated Ghostty terminal emulator";

  xdg.configFile = config.lib.dotfiles.configDirWith {
    dir = "ghostty";
    variant = "omarchy";
    exclude = [
      "config"
    ];
  };
}
