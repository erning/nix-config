{ pkgs, ... }:
{
  _description = "Java Development Kit";
  home.packages = with pkgs; [
    jdk
  ];
}
