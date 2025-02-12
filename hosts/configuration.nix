{ settings, ... }:

{
  imports =
    [
      (if settings.isDarwin then ./common/darwin.nix else ./common/nixos.nix)
      ./common/packages.nix
      ./common/secrets.nix
      ./common/users.nix
    ]
    ++ (
      let
        path = ./${settings.host};
      in
      with builtins;
      map (n: import (path + ("/" + n))) (
        filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
          attrNames (readDir path)
        )
      )
    );
}
