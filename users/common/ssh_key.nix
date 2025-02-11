{
  settings,
  config,
  inputs,
  ...
}:

{
  host ? settings.host,
  user ? settings.user,
  name ? "id_ed25519",
}:

let
  file = "ssh/${user}/${host}/${name}";
in
{
  age.secrets."${file}" = {
    file = "${inputs.secrets}/${file}.age";
    path = "${config.home.homeDirectory}/.ssh/${name}";
    mode = "600";
  };
  home.file.".ssh/${name}.pub".source = "${inputs.secrets}/${file}.pub";
}
