{ config, ... }:
{
  _description = "Omarchy-integrated Ghostty terminal emulator";

  xdg.configFile = config.lib.dotfiles.configDir {
    dir = "ghostty";
    variant = "omarchy";
    exclude = [
      "config"
    ];
  };

  # Leave Omarchy's ~/.config/ghostty/config unchanged. Manually append the
  # following line to the end of that file to load the managed font override:
  #
  #   config-file = ?"font.conf"
}
