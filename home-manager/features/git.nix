{
  settings,
  config,
  pkgs,
  ...
}:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  home.packages = with pkgs; [
    git
    delta
  ];

  xdg.configFile = {
    "git/config".source = symlink ".config/git/config";
    "git/config.darwin" = {
      enable = settings.isDarwin;
      source = symlink ".config/git/config.darwin";
    };
  };
}
