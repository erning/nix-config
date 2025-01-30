{ pkgs, ... }:

{
  home.packages = with pkgs; [
    git
    delta
  ];

  xdg.configFile = {
    "git/config".source = ../../dotfiles/.config/git/config;
    "git/config.darwin".source = ../../dotfiles/.config/git/config.darwin;
  };
}
