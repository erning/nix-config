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
    ./nixpkgs-config.nix
    ./nixpkgs-overlays.nix
    ../home-manager/home.nix
  ];
}
