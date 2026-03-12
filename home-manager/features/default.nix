{ inputs, ... }:

let
  mkFeatureImports = import "${inputs.self}/lib/mkFeatureImports.nix";
in
{
  imports = mkFeatureImports ./.;
}
