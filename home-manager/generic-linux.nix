{
  config,
  lib,
  pkgs,
  ...
}:

let
  # Splitting is delegated to awk (via -v RS=:) rather than shell IFS/for
  # word-splitting: zsh has SH_WORD_SPLIT off by default, so `for x in $path`
  # does not split on ":" there and silently no-ops the dedup. awk's field
  # splitting doesn't depend on the invoking shell, so it works the same
  # whether this script is sourced by bash, zsh, or a plain POSIX sh.
  normalizePath = import ../lib/normalize-path.nix {
    inherit config lib pkgs;
  };
in
{
  config = lib.mkIf config.targets.genericLinux.enable {
    # nix.sh only ever prepends the user profile bin ($HOME/.nix-profile/bin)
    # to PATH. The multi-user daemon profile bin normally reaches PATH via
    # /etc/profile.d on bash/sh login shells, but Fish never sources
    # /etc/profile, so list both explicitly here to keep them available (and
    # in a known position) for every shell genericLinux supports.
    home.sessionPath = lib.mkAfter [
      "$HOME/.nix-profile/bin"
      "/nix/var/nix/profiles/default/bin"
    ];

    # genericLinux sources nix.sh after home.sessionPath, which moves the user
    # Nix profile ahead of the preferred paths. Rebuild PATH afterwards so the
    # declared session paths take precedence while preserving the original
    # order of Nix and system paths.
    #
    # This normalize call itself lives inside hm-session-vars.sh, which
    # home-manager guards with an exported __HM_SESS_VARS_SOURCED marker so
    # it only runs once per shell environment. That guard is shared across
    # shell types: if a login shell of one kind (e.g. Fish) already sourced
    # it, a differently-typed login shell (e.g. bash) started underneath
    # inherits the marker and skips this block entirely — while the
    # system's own /etc/profile.d/nix.sh (nix-daemon.sh) has its own,
    # separate guard that Fish never trips, so it re-prepends its paths
    # unopposed. programs.bash.profileExtra below is the backstop for that.
    home.sessionVariablesExtra = lib.mkAfter normalizePath;

    # Bash sources nix.sh again from genericLinux's initExtra after .profile
    # has loaded the session variables. Normalize once more at the end of the
    # interactive shell initialization to keep the same ordering.
    programs.bash.initExtra = lib.mkAfter normalizePath;

    # Backstop for nested bash login shells (e.g. running `bash -l` from an
    # already-initialized Fish session, or any `bash -l -c '...'`): .profile
    # always runs profileExtra, interactive or not, regardless of whether
    # hm-session-vars.sh's own sourcing above was skipped by its
    # __HM_SESS_VARS_SOURCED guard. Without this, such a shell can end up
    # with the daemon Nix profile path duplicated at the front of PATH,
    # re-added by /etc/profile.d/nix.sh with no matching dedup pass.
    programs.bash.profileExtra = lib.mkAfter normalizePath;
  };
}
