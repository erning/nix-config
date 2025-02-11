{ settings, ... }:

{
  imports = [
    (if settings.isDarwin then ../hosts/common/darwin.nix else ../hosts/common/nixos.nix)
    ./common/packages.nix
    ./common/secrets.nix
    ./common/users.nix
    ./${settings.host}
  ];
}
