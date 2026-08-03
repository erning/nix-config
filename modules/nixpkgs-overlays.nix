{ inputs, settings, ... }:

let
  # nixpkgs-unstable has dropped x86_64-darwin, so pinned legacy hosts
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
