{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.starship;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.starship.enable = lib.mkEnableOption "starship";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = pkgs.unstable.starship;
    };

    xdg.configFile."starship.toml".source = symlink ".config/starship.toml";
  };
}
