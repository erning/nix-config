{
  config,
  lib,
  ...
}:

let
  cfg = config.features.bat;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf cfg.enable {
    programs.bat = lib.mkIf cfg.enable {
      enable = true;
    };

    xdg.configFile."bat/config".source = symlink ".config/bat/config";
    xdg.configFile."bat/themes".source = symlink ".config/bat/themes";
  };
}
