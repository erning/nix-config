{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neofetch
    vim
    git
    tmux

    fd
    ripgrep
    fzf
    bat
    btop

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
