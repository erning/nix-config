{ config, settings, lib, inputs, ... }:

let
  isDarwin = builtins.match ".*-darwin" settings.system != null;
in
{
  home.username = "${settings.user}";
  home.homeDirectory = (if isDarwin then "/Users" else "/home") + "/${settings.user}";

  lib.dotfiles = rec {
    path = "${config.home.homeDirectory}/.dotfiles";

    symlink = file:
      config.lib.file.mkOutOfStoreSymlink "${path}/${file}";

    configFiles = files:
      builtins.listToAttrs (map (file: {
        name = file;
        value.source = symlink ".config/${file}";
      }) files);

    homeFiles = files:
      builtins.listToAttrs (map (file: {
        name = file;
        value.source = symlink file;
      }) files);

    configDir = dir:
      import ../lib/symlink-dir.nix {
        mkSymlink = config.lib.file.mkOutOfStoreSymlink;
        src = "${inputs.self}/dotfiles/.config/${dir}";
        dst = "${path}/.config/${dir}";
        prefix = dir;
      };

    homeDir = dir:
      import ../lib/symlink-dir.nix {
        mkSymlink = config.lib.file.mkOutOfStoreSymlink;
        src = "${inputs.self}/dotfiles/${dir}";
        dst = "${path}/${dir}";
        prefix = dir;
      };
  };

  xdg.enable = true;

  home.sessionPath = lib.mkBefore [
    "$HOME/.local/bin"
  ];

  home.stateVersion = lib.mkDefault "26.05"; # Please read the comment before changing.
  programs.home-manager.enable = true;

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
