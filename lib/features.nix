{ lib, ... }:

let
  base = {
    fish.enable = lib.mkDefault true;
    bash.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    starship.enable = lib.mkDefault true;
    eza.enable = lib.mkDefault true;
    fzf.enable = lib.mkDefault true;
    bat.enable = lib.mkDefault true;

    vim.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;

    ssh.enable = lib.mkDefault true;
  };

  develop = {
    tmux.enable = lib.mkDefault true;
    neovim.enable = lib.mkDefault true;

    build-essential.enable = lib.mkDefault true;
    nix-support.enable = lib.mkDefault true;
    rustup.enable = lib.mkDefault true;
    zig.enable = lib.mkDefault true;
    python.enable = lib.mkDefault true;
    go.enable = lib.mkDefault true;

    just.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;

    typst.enable = lib.mkDefault true;
  } // base;

  console = {
    tmux.enable = lib.mkDefault true;
    neovim.enable = lib.mkDefault true;
    nushell.enable = lib.mkDefault true;
    zellij.enable = lib.mkDefault true;
    zoxide.enable = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
  } // base;

  desktop = {
    fonts.enable = lib.mkDefault true;
    fonts.source-han.enable = lib.mkDefault true;

    zed.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    kitty.enable = lib.mkDefault true;
    alacritty.enable = lib.mkDefault true;
  } // base;
in
{
  inherit base;
  inherit develop;
  inherit console;
  inherit desktop;
}
