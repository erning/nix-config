{
  nixpkgs,
  home-manager,
  inputs,
  ...
}:

{
  user,
  host,
  system,
}:

let
  pkgs = nixpkgs.legacyPackages.${system};
  isDarwin = if isNull (builtins.match ".*-darwin" system) then false else true;
  settings = {
    inherit user;
    inherit host;
    inherit system;
    isDarwin = isDarwin;
  };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    inherit settings;
    inherit inputs;
  };
  modules = [
    ../hosts/common/nixpkgs-config.nix
    ../hosts/common/nixpkgs-overlays.nix
    (if isDarwin then ../users/common/darwin.nix else ../users/common/nixos.nix)
    ../users/common/packages.nix
    ../users/common/secrets.nix
    ../home/home.nix
    ../users/${user}/${host}.nix
  ];
}
