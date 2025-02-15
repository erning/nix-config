{
  config,
  lib,
  ...
}:

let
  cfg = config.features.yazi;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.yazi.enable = lib.mkEnableOption "yazi";

  config = lib.mkIf cfg.enable {
    programs.yazi = lib.mkIf cfg.enable {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    xdg.configFile."yazi/theme.toml".source = symlink ".config/yazi/theme.toml";
  };
}
