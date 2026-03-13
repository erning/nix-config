{ pkgs, ... }:
{
  _description = "Python and uv";
  home.packages = with pkgs; [
    python3
    uv
  ];
}
