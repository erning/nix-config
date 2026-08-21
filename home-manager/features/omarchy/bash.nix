{ config, ... }:
{
  _description = "Omarchy-managed Bash shell";

  xdg.configFile = config.lib.dotfiles.configDir {
    dir = "bash";
    variant = "omarchy";
  };

  home.file = config.lib.dotfiles.homeFiles {
    files = [ ".bashrc" ];
    variant = "omarchy";
  };
}
