{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.vim;

  start = ".vim/pack/vendor/start";
  plugins = pkgs.vimPlugins;

  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.vim.enable = lib.mkEnableOption "vim";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vim
    ];

    home.file.".vim/vimrc".source = symlink ".config/vim/vimrc";

    home.file = {
      "${start}/onedark-vim".source = "${plugins.onedark-vim}";
      "${start}/vim-polyglot".source = "${plugins.vim-polyglot}";
      "${start}/editorconfig-vim".source = "${plugins.editorconfig-vim}";
      "${start}/lightline-vim".source = "${plugins.lightline-vim}";
    };
  };
}
