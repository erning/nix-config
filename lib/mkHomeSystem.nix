{
  nixpkgs,
  nix-darwin,
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
    (if isDarwin then home-manager.darwinModules else home-manager.nixosModules).home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit settings;
        inherit inputs;
      };
      home-manager.users.${user} = {
        imports = [ ../users ];
      };
      home-manager.backupFileExtension = "backup";
    }
  ];
}
