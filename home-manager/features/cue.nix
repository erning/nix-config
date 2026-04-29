{ pkgs, ... }:
{
  _description = "CUE data constraint language";
  home.packages = with pkgs; [
    cue
  ];
}
