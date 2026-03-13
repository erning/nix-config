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
    lazygit
  ];

  xdg.configFile = config.lib.dotfiles.configFiles [
    "git/config"
    "git/config.local"
    "git/catppuccin.gitconfig" # delta theme
    "lazygit/config.yml"
  ];

  home.file = config.lib.dotfiles.homeFiles [
    ".gitignore_global"
  ];
}
