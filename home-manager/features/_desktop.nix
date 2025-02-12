{ config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  imports = [
    ./_basic.nix
    ./fonts.nix
  ];

  xdg.configFile."zed/settings.json".source = symlink ".config/zed/settings.json";
  xdg.configFile."alacritty/alacritty.toml".source = symlink ".config/alacritty/alacritty.toml";
  xdg.configFile."ghostty/config".source = symlink ".config/ghostty/config";
  xdg.configFile."kitty/kitty.conf".source = symlink ".config/kitty/kitty.conf";
  xdg.configFile."kitty/kitty.app.png".source = symlink ".config/kitty/kitty.app.png";
  xdg.configFile."kitty/current-theme.conf".source = symlink ".config/kitty/current-theme.conf";
}
