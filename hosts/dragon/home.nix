{
  config,
  inputs,
  settings,
  ...
}:

let
  features = import "${inputs.self}/lib/features.nix";
  ssh-key = (import "${inputs.self}/lib/ssh-key.nix" { inherit config inputs; }) settings.host;
in
{
  imports = [
    (ssh-key "id_ed25519")
    (ssh-key "id_rsa")
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/keys.txt"
  ];

  features = features.console // features.desktop // features.develop;
}
