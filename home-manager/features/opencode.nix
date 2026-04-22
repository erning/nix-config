{ config, ... }:
{
  _description = "OpenCode CLI";
  xdg.configFile = config.lib.dotfiles.configFiles [
    "opencode/opencode.json"
    "opencode/tui.json"
    "opencode/oh-my-openagent.json"
  ];
}
