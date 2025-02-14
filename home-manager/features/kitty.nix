{ config, lib, ... }:

let
  cfg = config.features.kitty;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.kitty.enable = lib.mkEnableOption "kitty";
  config = lib.mkIf cfg.enable {
    xdg.configFile."kitty/kitty.conf".source = symlink ".config/kitty/kitty.conf";
    xdg.configFile."kitty/kitty.app.png".source = symlink ".config/kitty/kitty.app.png";
    xdg.configFile."kitty/current-theme.conf".source = symlink ".config/kitty/current-theme.conf";
  };
}
