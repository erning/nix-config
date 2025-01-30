{
  settings,
  config,
  inputs,
  ...
}:

let
  key.name = "id_ed25519";
  key.file = "ssh/${settings.user}/vm/${key.name}";
in
{
  imports = [
    ../../home/linux-desktop.nix
  ];

  age.secrets."${key.file}" = {
    file = "${inputs.secrets}/${key.file}.age";
    path = "${config.home.homeDirectory}/.ssh/${key.name}";
    mode = "600";
  };
  home.file.".ssh/${key.name}.pub".source = "${inputs.secrets}/${key.name}.pub";
}
