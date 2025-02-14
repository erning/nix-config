{ config, lib, ... }:

let
  cfg = config.features.zed;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.zed.enable = lib.mkEnableOption "zed";
  config = lib.mkIf cfg.enable {
    xdg.configFile."zed/settings.json".source = symlink ".config/zed/settings.json";
  };
}
