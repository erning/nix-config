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
    fzf
    ripgrep
    htop

    gnupg
    age
  ];
}
