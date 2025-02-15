{
  config,
  lib,
  pkgs,
  settings,
  ...
}:

let
  cfg = config.features.git;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
  isDarwin = builtins.match ".*-darwin" settings.system != null;
in
{
  options.features.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      git-lfs
      git-crypt
      delta
      lazygit
    ];

    xdg.configFile = {
      "git/config".source = symlink ".config/git/config";
      "git/config.darwin" = {
        enable = isDarwin;
        source = symlink ".config/git/config.darwin";
      };
      "lazygit/config.yml".source = symlink ".config/lazygit/config.yml";
    };
  };
}
