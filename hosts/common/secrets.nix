#
# agenix as the secret management tool
#
# preparing /etc/age/keys.txt on the target machine for decryption
#
{
  settings,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    (
      if settings.isDarwin then
        inputs.agenix.darwinModules.default
      else
        inputs.agenix.nixosModules.default
    )
  ];

  environment.systemPackages = with pkgs; [
    age
    inputs.agenix.packages."${settings.system}".default
    ssh-to-age
  ];

  age.identityPaths = [
    "/etc/age/keys.txt"
    "/etc/age/ssh_host_ed25519.txt"
  ];
  # ++ map (it: it.path) (lib.filter (it: it.type == "ed25519") config.services.openssh.hostKeys);

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
