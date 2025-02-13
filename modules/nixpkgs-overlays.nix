{ inputs, ... }:

let
  rootDir = "${inputs.self}";
  utils = import "${rootDir}/lib/utils.nix" { };
in
{
  nixpkgs.overlays = [
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
  ] ++ (utils.importPaths "${rootDir}/overlays");
}
