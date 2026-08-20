{
  config,
  lib,
  pkgs,
  ...
}:

let
  normalizePath = import ../../../lib/normalize-path.nix {
    inherit config lib pkgs;
  };
  pathHook = ''[[ -r "$HOME/.config/bash/path.bash" ]] && source "$HOME/.config/bash/path.bash"'';
in
{
  _description = "Omarchy-managed Bash shell";

  xdg.configFile."bash/path.bash".text = ''
    hmSessionVars="$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    if [[ -r "$hmSessionVars" ]]; then
      source "$hmSessionVars"
    fi
    unset hmSessionVars

    ${normalizePath}
  '';

  # Keep Omarchy's .bashrc intact and add only a stable bridge to the
  # Home Manager-owned PATH normalization script. Re-running activation is
  # idempotent and restores the bridge if an Omarchy refresh replaces .bashrc.
  home.activation.installOmarchyBashPathHook = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    bashrc="$HOME/.bashrc"
    pathHook=${lib.escapeShellArg pathHook}

    if [[ -f "$bashrc" ]] && ! grep -Fqx "$pathHook" "$bashrc"; then
      printf '\n%s\n' "$pathHook" >> "$bashrc"
    fi
  '';
}
