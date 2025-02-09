{
  nixpkgs,
  nix-darwin,
  inputs,
  config,
  ...
}:

{
  user ? null,
  host,
  system,
}:

let
  isDarwin = if isNull (builtins.match ".*-darwin" system) then false else true;
  settings = {
    inherit user;
    inherit host;
    inherit system;
    inherit isDarwin;
  };
in
(if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem) {
  inherit system;
  specialArgs = {
    inherit settings;
    inherit inputs;
  };
  modules = [
    (if isDarwin then ../hosts/common/darwin.nix else ../hosts/common/nixos.nix)
    ../hosts/common/nix-settings.nix
    ../hosts/common/nixpkgs-config.nix
    ../hosts/common/nixpkgs-overlays.nix
    ../hosts/common/packages.nix
    ../hosts/common/secrets.nix
    ../hosts/${host}
    ../hosts/common/users.nix
  ];
}