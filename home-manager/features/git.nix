{ config, pkgs, settings, inputs, ... }:

let
  isDarwin = builtins.match ".*-darwin" settings.system != null;
in
{
  home.packages = with pkgs; [
    git
    git-lfs
    git-crypt
    delta
    lazygit
  ];

  xdg.configFile = config.lib.dotfiles.configFiles [
    "git/config"
    "lazygit/config.yml"
  ] // {
    "git/darwin.gitconfig" = {
      enable = isDarwin;
      source = config.lib.dotfiles.symlink ".config/git/darwin.gitconfig";
    };
    "git/catppuccin.gitconfig".source = "${inputs.self}/dotfiles/.config/git/catppuccin.gitconfig";
  };
}
