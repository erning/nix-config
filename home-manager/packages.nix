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

    wget
    curl

    dig
    mtr
    rsync
    ifstat-legacy
  ];
}
