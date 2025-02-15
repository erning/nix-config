{ inputs, ... }:

let
  features = import "${inputs.self}/lib/features.nix";
in
{
  features = features.console // features.develop;
}
