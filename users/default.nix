{ settings, ... }:

{
  imports = [
    (if settings.isDarwin then ./common/darwin.nix else ./common/nixos.nix)
    ./common/packages.nix
    ./common/secrets.nix
    ../home-manager/home.nix
    ./${settings.host}/${settings.user}.nix
  ];
}
