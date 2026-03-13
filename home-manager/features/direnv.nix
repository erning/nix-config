{ pkgs, ... }:
{
  _description = "direnv environment manager";
  home.packages = with pkgs; [
    direnv
  ];
}
