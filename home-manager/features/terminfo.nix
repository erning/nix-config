{ pkgs, settings, ... }:

let
  # Both packages expose terminfo separately from the terminal application.
  terminfo = if settings.isDarwin then pkgs.ghostty-bin.terminfo else pkgs.ghostty.terminfo;
in
{
  _description = "Terminfo entries for local and SSH sessions";

  # Nix ncurses may not search the host system's database. The per-user
  # directory works even in SSH sessions without TERMINFO variables.
  # Link individual files to preserve other user-installed entries.
  home.file.".terminfo" = {
    source = "${terminfo}/share/terminfo";
    recursive = true;
  };
}
