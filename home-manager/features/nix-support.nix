{ pkgs, ... }:
{
  _description = "nix support";

  home.packages = with pkgs; [
    nil
    nixd
    nixfmt-rfc-style
  ];
}
