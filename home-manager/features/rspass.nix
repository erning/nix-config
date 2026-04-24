{ config, pkgs, ... }:
{
  _description = "minimal age-only command-line secret manager";
  home.packages = with pkgs; [
    rspass
  ];

  xdg.configFile = config.lib.dotfiles.configDir "rspass";
}
