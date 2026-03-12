#
# $ rustup default stable
# $ rustup component add rust-analyzer
#

{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rustup
  ];
}
