{ config, ... }:
{
  _description = "Factory AI droid CLI config with gopass-backed API keys";

  home.file = config.lib.dotfiles.homeFiles [
    ".factory/settings.json"
  ];

  xdg.configFile = config.lib.dotfiles.configFiles [
    "fish/functions/droid.fish"
  ];
}
