{ config, lib, ... }:

let
  cfg = config.features.claude-code;
in
{
  options.features.claude-code.enable = lib.mkEnableOption "claude-code";
  config = lib.mkIf cfg.enable {
    xdg.configFile = config.lib.dotfiles.configFiles [
      "cce/kimi.env"
      "cce/minimax.env"
      "cce/zhipu.env"
    ];
  };
}
