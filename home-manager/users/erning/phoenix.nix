{
  settings,
  config,
  inputs,
  ...
}:

{
  imports = [
    ../../features/_develop.nix
    (import ./_ssh_key.nix { inherit settings config inputs; } { })
  ];
}
