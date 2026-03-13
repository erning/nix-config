{ config, ... }:
{
  _description = "Claude Code CLI";
  xdg.configFile = config.lib.dotfiles.configFiles [
    "cce/kimi.env"
    "cce/minimax.env"
    "cce/zhipu.env"
  ];
}
