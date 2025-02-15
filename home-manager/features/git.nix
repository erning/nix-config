{
  config,
  lib,
  pkgs,
  settings,
  inputs,
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
      "git/darwin.gitconfig" = {
        enable = isDarwin;
        source = symlink ".config/git/darwin.gitconfig";
      };
      "git/catppuccin.gitconfig".source = "${inputs.self}/dotfiles/.config/git/catppuccin.gitconfig";
      "lazygit/config.yml".source = symlink ".config/lazygit/config.yml";
    };
  };
}
