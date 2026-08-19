{ inputs, lib, settings, ... }:

let
  # nixpkgs-unstable has dropped x86_64-darwin, so pinned hosts use their
  # own nixpkgs series as `pkgs.unstable` instead.
  unstableSrc =
    if settings.nixpkgsSeries == "default" then
      inputs.nixpkgs-unstable
    else
      inputs.${"nixpkgs-" + builtins.replaceStrings [ "." ] [ "" ] settings.nixpkgsSeries};
in
{
  nixpkgs.overlays = [
    (final: _: {
      # this allows you to access `pkgs.unstable` anywhere in your config
      unstable = import unstableSrc {
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;
      };
      # and `pkgs.stable`
      stable = import inputs.nixpkgs-stable {
        inherit (final.stdenv.hostPlatform) system;
        inherit (final) config;
      };
    })
  ]
  ++ (
    # Hydra no longer builds the Haskell package set for x86_64-darwin
    # on release-26.05, so pandoc and ShellCheck are not substitutable
    # and neither are packages that need them at build time (man pages,
    # shell script checks). Fall back to the cached 25.11 builds.
    lib.optionals (settings.nixpkgsSeries == "26.05") [
      (final: _: let
        pkgs2511 = import inputs.nixpkgs-2511 {
          inherit (final.stdenv.hostPlatform) system;
          config = builtins.removeAttrs final.config [ "replaceStdenv" ];
        };
      in {
        inherit (pkgs2511) eza yq-go shellcheck;
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
