{ inputs, ... }:

{
  nixpkgs.overlays =
    [
      (final: _: {
        # this allows you to access `pkgs.unstable` anywhere in your config
        unstable = import inputs.nixpkgs-unstable {
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
      map (n: import path + ("/" + n)) (
        filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
          attrNames (readDir path)
        )
      )
    );
}
