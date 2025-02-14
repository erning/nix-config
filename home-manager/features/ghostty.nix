{ config, lib, ... }:

let
  cfg = config.features.ghostty;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.ghostty.enable = lib.mkEnableOption "ghostty";
  config = lib.mkIf cfg.enable {
    xdg.configFile."ghostty/config".source = symlink ".config/ghostty/config";
  };
}
