{
  settings,
  config,
  inputs,
  ...
}:

{
  imports = [
    ../../features/_desktop.nix
    (import ./_ssh_key.nix { inherit settings config inputs; } { host = "vm"; })
  ];
}
