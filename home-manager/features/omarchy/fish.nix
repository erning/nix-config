{ config, ... }:

{
  _description = "Fish shell with Omarchy environment";

  programs.fish.enable = true;

  xdg.configFile = config.lib.dotfiles.configDirWith {
    dir = "fish";
    variant = "omarchy";
  };
}
