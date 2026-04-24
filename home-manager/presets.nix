{ lib, ... }:

let
  # === Building blocks (non-overlapping) ===

  core = {
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

  terminal = {
    tmux.enable = lib.mkDefault true;
    neovim.enable = lib.mkDefault true;
    nushell.enable = lib.mkDefault false;
    zellij.enable = lib.mkDefault true;
    zoxide.enable = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
  };

  languages = {
    rustup.enable = lib.mkDefault true;
    zig.enable = lib.mkDefault true;
    python.enable = lib.mkDefault true;
    go.enable = lib.mkDefault true;
    nodejs.enable = lib.mkDefault true;
    jdk.enable = lib.mkDefault true;
    kotlin.enable = lib.mkDefault true;
  };

  devtools = {
    nix-support.enable = lib.mkDefault true;
    just.enable = lib.mkDefault true;
    direnv.enable = lib.mkDefault true;
    gopass.enable = lib.mkDefault true;
    rspass.enable = lib.mkDefault true;
    gradle.enable = lib.mkDefault true;
    typst.enable = lib.mkDefault true;
    docker.enable = lib.mkDefault true;
    claude-code.enable = lib.mkDefault true;
    opencode.enable = lib.mkDefault true;
    pi-agent.enable = lib.mkDefault true;
    factory-droid.enable = lib.mkDefault true;
    yq.enable = lib.mkDefault true;
  };

  graphical = {
    fonts.enable = lib.mkDefault true;
    fonts.source-han.enable = lib.mkDefault true;
    fonts.maple-mono.enable = lib.mkDefault true;
    fonts.babelstone-han.enable = lib.mkDefault false;
    zed.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    kitty.enable = lib.mkDefault true;
    alacritty.enable = lib.mkDefault true;
    neovide.enable = lib.mkDefault true;
  };

  # === Composites (self-contained) ===

  development = core // terminal // languages // devtools;
  workstation = development // graphical;

in
{
  inherit
    core
    terminal
    languages
    devtools
    graphical
    ;
  inherit development workstation;
}
