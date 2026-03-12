{ config, lib, ... }:

let
  cfg = config.features.opencode;
in
{
  options.features.opencode.enable = lib.mkEnableOption "opencode";
  config = lib.mkIf cfg.enable {
    xdg.configFile = config.lib.dotfiles.configFiles [
      "opencode/opencode.json"
      "opencode/oh-my-opencode.json"
      "fish/functions/omo.fish"
    ];
  };
}
