{ config, ... }:
{
  _description = "Starship prompt";
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile = config.lib.dotfiles.configFiles [
    "starship.toml"
  ];
}
