{ config, ... }:

{
  _description = "Fish shell with Omarchy environment";

  programs.fish.enable = true;

  xdg.configFile = config.lib.dotfiles.configDir {
    dir = "fish";
    variant = "omarchy";
  };
}
