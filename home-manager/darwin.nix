{ config, lib, ... }:
{
  # Suppress warning: generateCaches has no effect when package is null (Darwin)
  # Fish sets generateCaches = true by default, but macOS uses system man (package = null)
  programs.man.generateCaches = lib.mkForce false;

  # Static, deduplicated equivalent of HM upstream's runtime-inherited
  # TERMINFO_DIRS: user profile first, then nix-darwin's profile-derived
  # paths, then the macOS fallback. The daemon profile path is kept
  # deliberately although it does not exist today, so terminfo installed
  # there later shows up automatically. HM upstream uses mkDefault, so a
  # plain assignment wins.
  home.sessionVariables.TERMINFO_DIRS = lib.concatStringsSep ":" [
    "${config.home.profileDirectory}/share/terminfo"
    "/run/current-system/sw/share/terminfo"
    "/nix/var/nix/profiles/default/share/terminfo"
    "/usr/share/terminfo"
  ];
}
