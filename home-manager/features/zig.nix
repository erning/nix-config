{ pkgs, ... }:
{
  _description = "Zig programming language";
  home.packages = with pkgs; [
    zig
  ];
}
