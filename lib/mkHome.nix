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
  settings = {
    inherit user;
    inherit host;
    inherit system;
  };
  rootDir = "${inputs.self}";
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = { inherit settings inputs; };
  modules = [
    "${rootDir}/modules/nixpkgs-config.nix"
    "${rootDir}/modules/nixpkgs-overlays.nix"
    "${rootDir}/home-manager/home.nix"
    "${rootDir}/hosts/${host}/home.nix"
  ];
}
