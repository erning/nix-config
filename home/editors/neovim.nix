{ pkgs, ... }:

let
  lazyvim = "NVIM_APPNAME=nvim-lazyvim nvim";
in
{
  home.packages = with pkgs; [
    neovim
    gcc # compiler for tree-sitter
  ];

  xdg.configFile = {
    "nvim-lazyvim" = {
      source = ../../dotfiles/.config/nvim-lazyvim;
      recursive = true;
    };
  };

  programs.fish.shellAliases.vi = "${lazyvim}";
  programs.bash.shellAliases.vi = "${lazyvim}";
  programs.zsh.shellAliases.vi = "${lazyvim}";
}
