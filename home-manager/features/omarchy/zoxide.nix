{ lib, ... }:
{
  _description = "Omarchy-provided zoxide directory jumper";

  programs.fish.interactiveShellInit = lib.mkAfter ''
    if type -q zoxide
      zoxide init fish | source
    end
  '';

  programs.zsh.initContent = lib.mkAfter ''
    if command -v zoxide >/dev/null; then
      eval "$(zoxide init zsh)"
    fi
  '';
}
