{ pkgs, ... }:
{
  _description = "gopass password store with age backend";
  home.packages = with pkgs; [
    gopass
    age
  ];
}
