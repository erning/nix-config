{
  settings,
  config,
  inputs,
  ...
}:

{
  imports =
    let
      ssh_key = import ../common/ssh_key.nix { inherit settings config inputs; };
    in
    [
      ../../home/macos.nix
      (ssh_key { name = "id_ed25519"; })
      (ssh_key { name = "id_rsa"; })
    ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/primary.key"
  ];
}
