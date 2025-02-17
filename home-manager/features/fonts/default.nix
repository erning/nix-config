{ inputs, ... }:

let
  scanFiles = import "${inputs.self}/lib/scan-files.nix";
in
{
  imports = (scanFiles ./.);
}
