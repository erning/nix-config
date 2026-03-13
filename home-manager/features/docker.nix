{ pkgs, ... }:
{
  _description = "Docker tools (lazydocker)";
  home.packages = with pkgs; [
    lazydocker
  ];
}
