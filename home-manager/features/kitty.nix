{ config, lib, ... }:

let
  cfg = config.features.kitty;
in
{
  options.features.kitty.enable = lib.mkEnableOption "kitty";
  config = lib.mkIf cfg.enable {
    xdg.configFile = config.lib.dotfiles.configFiles [
      "kitty/kitty.conf"
      "kitty/kitty.app.png"
      "kitty/current-theme.conf"
    ];
  };
}
