{ config, inputs, ... }:

host: name: {
  age.secrets."ssh/${host}/${name}" = {
    file = "${inputs.secrets}/ssh/${host}/${name}.age";
    path = "${config.home.homeDirectory}/.ssh/${name}";
    mode = "600";
  };
  home.file.".ssh/${name}.pub".source = "${inputs.secrets}/ssh/${host}/${name}.pub";
}
