{ lib, ... }:
{
  _description = "Omarchy-provided fzf fuzzy finder";

  programs.fish.interactiveShellInit = lib.mkAfter ''
    if type -q fzf
      fzf --fish | source
    end
  '';

  programs.zsh.initContent = lib.mkAfter ''
    if command -v fzf >/dev/null; then
      source <(fzf --zsh)
    fi
  '';
}
