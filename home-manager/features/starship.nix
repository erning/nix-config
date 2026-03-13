{ config, pkgs, ... }:
{
  _description = "Starship prompt";
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    package = pkgs.unstable.starship;
  };

  xdg.configFile = config.lib.dotfiles.configFiles [
    "starship.toml"
  ];
}
