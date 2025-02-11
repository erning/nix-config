{
  settings,
  config,
  inputs,
  ...
}:

{
  imports = [
    ../../home-manager/macos.nix
    (import ../common/ssh_key.nix { inherit settings config inputs; } { })
  ];
}
