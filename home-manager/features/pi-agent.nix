{ config, ... }:
{
  _description = "pi coding agent config with gopass-backed API keys";

  home.file = config.lib.dotfiles.homeFiles [
    ".pi/agent/models.json"
  ];
}
