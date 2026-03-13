{ pkgs, ... }:
{
  _description = "Just command runner";
  home.packages = with pkgs; [
    just
  ];
}
