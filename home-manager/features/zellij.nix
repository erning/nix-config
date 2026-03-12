{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    zellij
  ];
  xdg.configFile = config.lib.dotfiles.configFiles [
    "zellij/config.kdl"
  ];
}
