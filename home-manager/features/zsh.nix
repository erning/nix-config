{ config, ... }:
{
  _description = "Zsh shell";
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
  };
}
