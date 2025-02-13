{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neofetch
    vim
    git
  ];
}
