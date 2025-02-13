{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.git;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      delta
    ];

    xdg.configFile = {
      "git/config".source = symlink ".config/git/config";
      "git/config.darwin" = {
        enable = pkgs.stdenv.isDarwin;
        source = symlink ".config/git/config.darwin";
      };
    };
  };
}
