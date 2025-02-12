#
# common packages that I use on all machines
#
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
