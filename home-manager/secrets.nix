{ config, inputs, ... }:

{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/keys.txt"
    "/etc/age/keys.txt"
    "/etc/age/ssh_host_ed25519.txt"
  ];
}
