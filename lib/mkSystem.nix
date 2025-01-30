{
  nixpkgs,
  nix-darwin,
  inputs,
  config,
  ...
}:

{
  host,
  system,
}:

let
  isDarwin = if isNull (builtins.match ".*-darwin" system) then false else true;
  settings = {
    inherit host;
    inherit system;
    inherit isDarwin;
  };
  helpers = import ./helpers { inherit settings config inputs; };
in
(if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem) {
  inherit system;
  specialArgs = {
    inherit settings;
    inherit inputs;
    inherit helpers;
  };
  modules = [
    (if isDarwin then ../hosts/common/darwin.nix else ../hosts/common/nixos.nix)
    ../hosts/common/nix-settings.nix
    ../hosts/common/nixpkgs-config.nix
    ../hosts/common/nixpkgs-overlays.nix
    ../hosts/common/packages.nix
    ../hosts/common/secrets.nix
    ../hosts/${host}
  ];
}
