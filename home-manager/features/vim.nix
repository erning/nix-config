{ config, pkgs, ... }:

let
  start = ".vim/pack/vendor/start";
  plugins = pkgs.vimPlugins;
in
{
  home.packages = with pkgs; [
    vim
  ];

  home.file.".vim/vimrc".source = config.lib.dotfiles.symlink ".config/vim/vimrc";

  home.file = {
    "${start}/catppuccin-vim".source = "${plugins.catppuccin-vim}";
    "${start}/vim-polyglot".source = "${plugins.vim-polyglot}";
    "${start}/editorconfig-vim".source = "${plugins.editorconfig-vim}";
    "${start}/lightline-vim".source = "${plugins.lightline-vim}";
  };
}
