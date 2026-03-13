{ config, ... }:
{
  _description = "OpenCode CLI";
  xdg.configFile = config.lib.dotfiles.configFiles [
    "opencode/opencode.json"
    "opencode/oh-my-opencode.json"
    "fish/functions/omo.fish"
  ];
}
