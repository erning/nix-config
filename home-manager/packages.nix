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
    htop

    gnupg
    age
  ];
}
