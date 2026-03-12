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
  };
}
