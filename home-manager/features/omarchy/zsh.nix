{ config, lib, ... }:

{
  _description = "Zsh shell with Omarchy environment";

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    initContent = lib.mkBefore ''
      [[ -r "${config.xdg.configHome}/zsh/omarchy.zsh" ]] && source "${config.xdg.configHome}/zsh/omarchy.zsh"
    '';
  };

  xdg.configFile = config.lib.dotfiles.configDir {
    dir = "zsh";
    variant = "omarchy";
  };
}
