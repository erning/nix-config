{ inputs, ... }:

{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age.identityPaths = [
    "/etc/age/keys.txt"
    "/etc/age/ssh_host_ed25519.txt"
  ];
}
