{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.zellij;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.zellij.enable = lib.mkEnableOption "zellij";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      zellij
    ];
    xdg.configFile."zellij/config.kdl".source = symlink ".config/zellij/config.kdl";
  };
}
