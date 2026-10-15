{ config, pkgs, ... }:
{
  _description = "cida CLI that translates and improves text with a configured language model";
  home.packages = with pkgs; [
    cida-cli
  ];

  xdg.configFile = config.lib.dotfiles.configDir "cida";
}
