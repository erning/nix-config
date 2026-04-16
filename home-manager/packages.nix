{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
    vim
    git
    tmux

    fd
    ripgrep
    fzf
    bat
    htop

    gnupg
    age
    sops

    wget
    curl
    coreutils

    dig
    mtr
    rsync
    ifstat-legacy
    pstree
    tree
  ];
}
