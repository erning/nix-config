{ pkgs, settings, ... }:

{
  home.username = "${settings.user}";
  home.homeDirectory = (if pkgs.stdenv.isDarwin then "/Users" else "/home") + "/${settings.user}";

  home.stateVersion = "24.11"; # Please read the comment before changing.
  programs.home-manager.enable = true;

  #
  #
  #
  imports = [
    ./packages.nix
    ./homebrew.nix
    ./features
  ];

}
