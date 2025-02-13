{
  nixpkgs,
  nix-darwin,
  inputs,
  ...
}:

{
  host,
  system,
}:
let
  isDarwin = builtins.match ".*-darwin" system != null;
  settings = {
    inherit host;
    inherit system;
  };

  rootDir = "${inputs.self}";

in
(if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem) {
  inherit system;
  specialArgs = { inherit settings inputs; };
  modules = [
    "${rootDir}/modules/system.nix"
    "${rootDir}/hosts/${host}/configuration.nix"
  ];

}
