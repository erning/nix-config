#
# $ rustup default stable
# $ rustup component add rust-analyzer
#

{ pkgs, ... }:
{
  _description = "Rust toolchain (rustup)";
  home.packages = with pkgs; [
    rustup
  ];
}
