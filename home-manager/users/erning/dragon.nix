{
  settings,
  config,
  inputs,
  ...
}:

let
  ssh_key = import ./_ssh_key.nix { inherit settings config inputs; };
in
{
  imports = [
    ../../features/_macos.nix
    (ssh_key { name = "id_ed25519"; })
    (ssh_key { name = "id_rsa"; })
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/primary.key"
  ];
}
