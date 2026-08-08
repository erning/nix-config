{
  config,
  lib,
  pkgs,
  ...
}:

let
  preferredPath = lib.concatStringsSep ":" config.home.sessionPath;
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
