{
  nixpkgs,
  nix-darwin,
  inputs,
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
    ./nix-settings.nix
    ./nixpkgs-config.nix
    ./nixpkgs-overlays.nix
    ../hosts
  ];
}
