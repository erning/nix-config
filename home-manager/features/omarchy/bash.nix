{
  config,
  lib,
  ...
}:

let
  hmHook = ''[[ -r "$HOME/.config/bash/hm.bashrc" ]] && source "$HOME/.config/bash/hm.bashrc"'';
  legacyPathHook = ''[[ -r "$HOME/.config/bash/path.bash" ]] && source "$HOME/.config/bash/path.bash"'';
in
{
  _description = "Omarchy-managed Bash shell";

  xdg.configFile = config.lib.dotfiles.configDir {
    dir = "bash";
    variant = "omarchy";
  };

  # Keep Omarchy's .bashrc intact and add only a stable bridge to the
  # Home Manager-owned shell additions. Re-running activation is
  # idempotent and restores the bridge if an Omarchy refresh replaces .bashrc.
  home.activation.installOmarchyBashHmHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    bashrc="$HOME/.bashrc"
    hmHook=${lib.escapeShellArg hmHook}
    legacyPathHook=${lib.escapeShellArg legacyPathHook}

    if [[ -f "$bashrc" ]] && grep -Fqx "$legacyPathHook" "$bashrc"; then
      grep -Fvx "$legacyPathHook" "$bashrc" > "$bashrc.hm-tmp" || true
      mv "$bashrc.hm-tmp" "$bashrc"
    fi

    if [[ -f "$bashrc" ]] && ! grep -Fqx "$hmHook" "$bashrc"; then
      printf '\n%s\n' "$hmHook" >> "$bashrc"
    fi
  '';
}
