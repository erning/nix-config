{ pkgs, ... }:
{
  _description = "yq YAML/JSON/TOML processor";
  home.packages = with pkgs; [
    yq-go
  ];
}
