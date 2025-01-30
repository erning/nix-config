{ pkgs, ... }:

let
  start = ".vim/pack/vendor/start";
  plugins = pkgs.vimPlugins;
in
{
  home.packages = with pkgs; [
    vim
  ];

  home.file.".vim".source = ../../dotfiles/.config/vim;
  home.file.".vim".recursive = true;

  home.file = {
    "${start}/onedark-vim".source = "${plugins.onedark-vim}";
    "${start}/vim-polyglot".source = "${plugins.vim-polyglot}";
    "${start}/editorconfig-vim".source = "${plugins.editorconfig-vim}";
    "${start}/lightline-vim".source = "${plugins.lightline-vim}";
  };
}
