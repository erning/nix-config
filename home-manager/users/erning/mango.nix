{
  settings,
  config,
  inputs,
  ...
}:

{
  imports = [
    ../../features/_macos.nix
    (import ./_ssh_key.nix { inherit settings config inputs; } { })
  ];
}
