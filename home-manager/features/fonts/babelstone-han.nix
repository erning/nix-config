{ pkgs, ... }:
{
  _description = "fonts - BabelStone Han";

  home.packages = with pkgs.unstable; [
    babelstone-han
  ];
}
