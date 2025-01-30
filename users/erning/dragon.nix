{
  settings,
  config,
  inputs,
  ...
}:

let
  ssh_key =
    name:
    let
      file = "ssh/${settings.user}/${settings.host}/${name}";
    in
    {
      age.secrets."${file}" = {
        file = "${inputs.secrets}/${file}.age";
        path = "${config.home.homeDirectory}/.ssh/${name}";
        mode = "600";
      };
      home.file.".ssh/${name}.pub".source = "${inputs.secrets}/${name}.pub";
    };
in
{
  imports = [
    ../../home/macos.nix
    (ssh_key "id_ed25519")
    (ssh_key "id_rsa")
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/primary.key"
  ];
}
