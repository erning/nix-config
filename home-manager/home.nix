{
  config,
  settings,
  lib,
  inputs,
  ...
}:

let
  # Tags considered when resolving `file##<tag>` alternates. See
  # `lib/alternate-match.nix` for the full priority spec; in short:
  # host > os > series > base file.
  matchers = {
    host = settings.host;
    os = if settings.isDarwin then "darwin" else "linux";
    series = settings.nixpkgsSeries;
  };
  alt = import ../lib/alternate-match.nix { inherit matchers; };
in
{
  home.username = "${settings.user}";
  home.homeDirectory = (if settings.isDarwin then "/Users" else "/home") + "/${settings.user}";

  lib.dotfiles = rec {
    path = "${config.home.homeDirectory}/.dotfiles";
    srcPath = "${inputs.self}/dotfiles";
    host = settings.host;

    # Pick the highest-priority alternate that exists on disk; fall back to base.
    resolve =
      file:
      let
        hits = builtins.filter (
          suffix: builtins.pathExists "${srcPath}/${file}##${suffix}"
        ) alt.candidateSuffixes;
      in
      if hits != [ ] then "${file}##${builtins.head hits}" else file;

    # True if the base file or any candidate alternate exists.
    exists =
      file:
      builtins.any (
        suffix: builtins.pathExists "${srcPath}/${file}##${suffix}"
      ) alt.candidateSuffixes
      || builtins.pathExists "${srcPath}/${file}";

    symlink = file: config.lib.file.mkOutOfStoreSymlink "${path}/${resolve file}";

    configFiles =
      files:
      builtins.listToAttrs (
        builtins.concatMap (
          file:
          let
            dotFile = ".config/${file}";
          in
          if exists dotFile then
            [
              {
                name = file;
                value.source = config.lib.file.mkOutOfStoreSymlink "${path}/${resolve dotFile}";
              }
            ]
          else
            [ ]
        ) files
      );

    homeFiles =
      files:
      builtins.listToAttrs (
        builtins.concatMap (
          file:
          if exists file then
            [
              {
                name = file;
                value.source = config.lib.file.mkOutOfStoreSymlink "${path}/${resolve file}";
              }
            ]
          else
            [ ]
        ) files
      );

    configDir =
      dir:
      import ../lib/symlink-dir.nix {
        mkSymlink = config.lib.file.mkOutOfStoreSymlink;
        src = "${srcPath}/.config/${dir}";
        dst = "${path}/.config/${dir}";
        prefix = dir;
        inherit matchers;
      };

    homeDir =
      dir:
      import ../lib/symlink-dir.nix {
        mkSymlink = config.lib.file.mkOutOfStoreSymlink;
        src = "${srcPath}/${dir}";
        dst = "${path}/${dir}";
        prefix = dir;
        inherit matchers;
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
    (if settings.isDarwin then ./darwin.nix else ./nixos.nix)
    ./packages.nix
    ./secrets.nix
    ./features
  ];
}
