{ settings, ... }:

let
  isDarwin = builtins.match ".*-darwin" settings.system != null;
in
{
  home.username = "${settings.user}";
  home.homeDirectory = (if isDarwin then "/Users" else "/home") + "/${settings.user}";

  home.stateVersion = "24.11"; # Please read the comment before changing.
  programs.home-manager.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  #
  #
  #
  imports = [
    (if isDarwin then ./darwin.nix else ./nixos.nix)
    ./packages.nix
    ./secrets.nix
    ./features
  ];

}
