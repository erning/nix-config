{ pkgs, ... }:
{
  _description = "nvd Nix package version diff tool";
  home.packages = with pkgs; [
    nvd
  ];
}
