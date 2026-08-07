{ pkgs, ... }:
{
  _description = "Asciinema terminal session recorder";
  home.packages = with pkgs; [
    asciinema
  ];
}
