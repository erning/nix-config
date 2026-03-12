{ pkgs, ... }:
{
  _description = "fonts - Source Han";

  home.packages = with pkgs.unstable; [
    source-han-sans
    source-han-serif
    source-han-mono
  ];
}
