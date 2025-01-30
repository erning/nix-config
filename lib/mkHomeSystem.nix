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
    (if isDarwin then ../hosts/common/darwin.nix else ../hosts/common/nixos.nix)
    ../hosts/common/nix-settings.nix
    ../hosts/common/nixpkgs-config.nix
    ../hosts/common/nixpkgs-overlays.nix
    ../hosts/common/packages.nix
    ../hosts/common/secrets.nix
    ../hosts/${host}
    ../hosts/common/users.nix
    (if isDarwin then home-manager.darwinModules else home-manager.nixosModules).home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit settings;
        inherit inputs;
      };
      home-manager.users.${user} = {
        imports = [
          (if isDarwin then ../users/common/darwin.nix else ../users/common/nixos.nix)
          ../users/common/packages.nix
          ../users/common/secrets.nix
          ../home/home.nix
          ../users/${user}/${host}.nix
        ];
      };
      home-manager.backupFileExtension = "backup";
    }
  ];
}
