{ config, settings, ... }:
{
  _description = "Zsh shell";
  programs.zsh = {
    enable = true;
    # home-manager 25.05 mishandles absolute dotDir and generates
    # `source $HOME//Users/.../.zshenv` in ~/.zshenv. Fixed by PR #8378
    # post-25.05, so fall back to a relative path on that series.
    dotDir =
      if settings.nixpkgsSeries == "25.05" then
        ".config/zsh"
      else
        "${config.xdg.configHome}/zsh";
  };
}
