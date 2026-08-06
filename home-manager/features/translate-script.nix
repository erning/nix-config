{ pkgs, ... }:
{
  _description = "translate CLI that wraps pi to translate text between English and Simplified Chinese";
  home.packages = with pkgs; [
    translate-script
  ];
}
