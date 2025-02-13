{
  pkgs,
  settings,
  inputs,
  ...
}:

let
  agenixModules =
    if builtins.match ".*-darwin" settings.system != null then
      inputs.agenix.darwinModules.default
    else
      inputs.agenix.nixosModules.default;
in
{
  imports = [ agenixModules ];

  environment.systemPackages = with pkgs; [
    age
    ssh-to-age
    inputs.agenix.packages."${pkgs.system}".default
  ];

  age.identityPaths = [
    "/etc/age/keys.txt"
    "/etc/age/ssh_host_ed25519.txt"
  ];

  system.activationScripts."age-ssh_host_ed25519.txt".text = ''
    if [ -f /etc/ssh/ssh_host_ed25519_key ]; then
      mkdir -p /etc/age
      ${pkgs.ssh-to-age.outPath}/bin/ssh-to-age \
        -private-key \
        -i /etc/ssh/ssh_host_ed25519_key \
        -o /etc/age/ssh_host_ed25519.txt
    fi
  '';
}
