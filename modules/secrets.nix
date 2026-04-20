{
  pkgs,
  settings,
  inputs,
  ...
}:

let
  agenixModules =
    if settings.isDarwin then
      inputs.agenix.darwinModules.default
    else
      inputs.agenix.nixosModules.default;
in
{
  imports = [ agenixModules ];

  environment.systemPackages = with pkgs; [
    age
    ssh-to-age
    inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  age.identityPaths = [
    "/etc/age/keys.txt"
    "/etc/age/ssh_host_ed25519.txt"
  ];

  # nix-darwin's system.activationScripts only runs a hardcoded set of script
  # names (see nix-darwin/nix-darwin#663); custom names are silently dropped.
  # On darwin we attach to the officially-user-customizable extraActivation
  # hook; NixOS iterates all attrs, so we keep a descriptive custom name there.
  system.activationScripts =
    let
      script = ''
        if [ -f /etc/ssh/ssh_host_ed25519_key ]; then
          mkdir -p /etc/age
          ${pkgs.ssh-to-age.outPath}/bin/ssh-to-age \
            -private-key \
            -i /etc/ssh/ssh_host_ed25519_key \
            -o /etc/age/ssh_host_ed25519.txt
        fi
      '';
    in
    if settings.isDarwin then
      { extraActivation.text = script; }
    else
      { "age-ssh_host_ed25519.txt".text = script; };
}
