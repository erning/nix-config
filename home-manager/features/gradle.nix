{ pkgs, ... }:
{
  _description = "Gradle build system";
  home.packages = with pkgs; [
    gradle
  ];
}
