{
  settings,
  config,
  inputs,
  ...
}:

{
  imports = [
    ../../home/macos.nix
    (import ../common/ssh_key.nix { inherit settings config inputs; } { name = "id_25519"; })
    (import ../common/ssh_key.nix { inherit settings config inputs; } { name = "id_rsa"; })
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/primary.key"
  ];
}
