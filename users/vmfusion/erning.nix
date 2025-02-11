{
  settings,
  config,
  inputs,
  ...
}:

{
  imports = [
    ../../home/linux-desktop.nix
    (import ../common/ssh_key.nix { inherit settings config inputs; } { host = "vm"; })
  ];
}
