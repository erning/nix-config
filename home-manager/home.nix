{ config, settings, lib, inputs, ... }:

let
  isDarwin = builtins.match ".*-darwin" settings.system != null;
in
{
  home.username = "${settings.user}";
  home.homeDirectory = (if isDarwin then "/Users" else "/home") + "/${settings.user}";

  lib.dotfiles = rec {
    path = "${config.home.homeDirectory}/.dotfiles";
    srcPath = "${inputs.self}/dotfiles";
    host = settings.host;

    # Resolve best alternate: ##host > ##h.host > ##hostname.host > base file
    resolve = file:
      let
        check = suffix: builtins.pathExists "${srcPath}/${file}##${suffix}";
      in
      if check host then "${file}##${host}"
      else if check "h.${host}" then "${file}##h.${host}"
      else if check "hostname.${host}" then "${file}##hostname.${host}"
      else file;

    # Check whether any variant (host alternate or base) exists
    exists = file:
      builtins.pathExists "${srcPath}/${file}##${host}"
      || builtins.pathExists "${srcPath}/${file}##h.${host}"
      || builtins.pathExists "${srcPath}/${file}##hostname.${host}"
      || builtins.pathExists "${srcPath}/${file}";

    symlink = file:
      config.lib.file.mkOutOfStoreSymlink "${path}/${resolve file}";

    configFiles = files:
      builtins.listToAttrs (
        builtins.concatMap (file:
          let dotFile = ".config/${file}";
          in if exists dotFile then [{
            name = file;
            value.source = config.lib.file.mkOutOfStoreSymlink
              "${path}/${resolve dotFile}";
          }] else []
        ) files
      );

    homeFiles = files:
      builtins.listToAttrs (
        builtins.concatMap (file:
          if exists file then [{
            name = file;
            value.source = config.lib.file.mkOutOfStoreSymlink
              "${path}/${resolve file}";
          }] else []
        ) files
      );

    configDir = dir:
      import ../lib/symlink-dir.nix {
        mkSymlink = config.lib.file.mkOutOfStoreSymlink;
        src = "${srcPath}/.config/${dir}";
        dst = "${path}/.config/${dir}";
        prefix = dir;
        inherit host;
      };

    homeDir = dir:
      import ../lib/symlink-dir.nix {
        mkSymlink = config.lib.file.mkOutOfStoreSymlink;
        src = "${srcPath}/${dir}";
        dst = "${path}/${dir}";
        prefix = dir;
        inherit host;
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
