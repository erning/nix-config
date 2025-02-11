{
  settings,
  config,
  inputs,
  ...
}:

{
  imports = [
    ../../home/linux-console.nix
    (import ../common/ssh_key.nix { inherit settings config inputs; } { })
  ];
}
