{
  config,
  lib,
  pkgs,
  ...
}:

let
  preferredPath = lib.concatStringsSep ":" config.home.sessionPath;

  # Splitting is delegated to awk (via -v RS=:) rather than shell IFS/for
  # word-splitting: zsh has SH_WORD_SPLIT off by default, so `for x in $path`
  # does not split on ":" there and silently no-ops the dedup. awk's field
  # splitting doesn't depend on the invoking shell, so it works the same
  # whether this script is sourced by bash, zsh, or a plain POSIX sh.
  normalizePath = ''
    hmPreferredPath="${preferredPath}"
    export PATH="$(
      printf '%s:%s' "$hmPreferredPath" "$PATH" |
        ${pkgs.gawk}/bin/awk -v RS=: '
          length($0) && !seen[$0]++ {
            output = output (length(output) ? ":" : "") $0
          }
          END { printf "%s", output }
        '
    )"
    unset hmPreferredPath
  '';
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
    home.sessionVariablesExtra = lib.mkAfter normalizePath;

    # Bash sources nix.sh again from genericLinux's initExtra after .profile
    # has loaded the session variables. Normalize once more at the end of the
    # interactive shell initialization to keep the same ordering.
    programs.bash.initExtra = lib.mkAfter normalizePath;
  };
}
