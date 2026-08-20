{
  config,
  lib,
  pkgs,
}:

let
  preferredPath = lib.concatStringsSep ":" config.home.sessionPath;
in
''
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
''
