{ pkgs, ... }:
{
  _description = "Kotlin programming language";
  home.packages = with pkgs; [
    kotlin
  ];
}
