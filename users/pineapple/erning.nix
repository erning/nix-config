{
  settings,
  config,
  inputs,
  ...
}:

{
  imports = [
    ../../home/macos.nix
    (import ../common/ssh_key.nix { inherit settings config inputs; } { })
  ];
}
