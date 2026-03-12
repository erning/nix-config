{ config, lib, ... }:

let
  cfg = config.features.alacritty;
in
{
  options.features.alacritty.enable = lib.mkEnableOption "alacritty";
  config = lib.mkIf cfg.enable {
    xdg.configFile = config.lib.dotfiles.configFiles [
      "alacritty/alacritty.toml"
    ];
  };
}
