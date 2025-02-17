{ inputs, lib, ... }:

let
  features = import "${inputs.self}/lib/features.nix" { inherit lib; };
in
{
  features = lib.mkMerge [
    features.console
    features.develop
  ];
}
