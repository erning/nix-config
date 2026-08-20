{
  config,
  pkgs,
  ...
}:

{
  _description = "Git and related tools";
  home.packages = with pkgs; [
    git
    git-lfs
    git-crypt
    delta
  ];

  xdg.configFile = config.lib.dotfiles.configFiles [
    "git/config"
    "git/config.local"
    "git/catppuccin.gitconfig" # delta theme
  ];

  home.file = config.lib.dotfiles.homeFiles [
    ".gitignore_global"
  ];
}
