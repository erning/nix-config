{ config, lib, ... }:

let
  cfg = config.features.alacritty;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.alacritty.enable = lib.mkEnableOption "alacritty";
  config = lib.mkIf cfg.enable {
    xdg.configFile."alacritty/alacritty.toml".source = symlink ".config/alacritty/alacritty.toml";
  };
}
