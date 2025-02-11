{
  settings,
  config,
  inputs,
  ...
}:

{
  imports = [
    ../../home-manager/linux-console.nix
    (import ../common/ssh_key.nix { inherit settings config inputs; } { })
  ];
}
