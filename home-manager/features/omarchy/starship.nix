{ config, lib, ... }:

{
  _description = "Omarchy-provided Starship prompt";

  programs.fish.interactiveShellInit = lib.mkAfter ''
    if test "$TERM" != "dumb"; and type -q starship
      starship init fish | source
    end
  '';

  programs.zsh.initContent = lib.mkAfter ''
    if [[ $TERM != "dumb" ]] && command -v starship >/dev/null; then
      eval "$(starship init zsh)"
    fi
  '';

  xdg.configFile = config.lib.dotfiles.configFiles [
    "starship.toml"
  ];
}
