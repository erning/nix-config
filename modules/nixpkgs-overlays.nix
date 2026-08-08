{ inputs, lib, settings, ... }:

let
  # nixpkgs-unstable has dropped x86_64-darwin, so the pinned Intel host
  # cannot import it at all. On a pinned series, alias `pkgs.unstable`
  # to that series' own pinned nixpkgs instead.
  unstableSrc =
    if settings.nixpkgsSeries == "default" then
      inputs.nixpkgs-unstable
    else
      inputs.${"nixpkgs-" + builtins.replaceStrings [ "." ] [ "" ] settings.nixpkgsSeries};
in
{
  nixpkgs.overlays = [
    (final: _: let
      # replaceStdenv defaults to null in final.config; older branches
      # (25.11) call it unconditionally, so drop it when re-importing.
      config = builtins.removeAttrs final.config [ "replaceStdenv" ];
    in {
      # this allows you to access `pkgs.unstable` anywhere in your config
      unstable = import unstableSrc {
        inherit (final.stdenv.hostPlatform) system;
        inherit config;
      };
      # and `pkgs.stable`
      stable = import inputs.nixpkgs-stable {
        inherit (final.stdenv.hostPlatform) system;
        inherit config;
      };
    })
  ]
  ++ (
    # Hydra no longer builds the Haskell package set for x86_64-darwin
    # on release-26.05, so pandoc and ShellCheck are not substitutable
    # and neither are packages that need them at build time (man pages,
    # shell script checks). Fall back to the cached 25.11 builds.
    lib.optionals (settings.nixpkgsSeries == "26.05") [
      (final: _: {
        inherit (final.stable) eza yq-go shellcheck;
      })
    ]
  )
  ++ (
    let
      path = "${inputs.self}/overlays";
    in
    with builtins;
    map (n: import (path + ("/" + n))) (
      filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
        attrNames (readDir path)
      )
    )
  );
}
