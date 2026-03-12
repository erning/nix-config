{ config, inputs, ... }:

host: name: {
  age.secrets."ssh/${host}/${name}" = {
    file = "${inputs.secrets}/ssh/${host}/${name}.age";
    path = "${config.home.homeDirectory}/.ssh/${name}";
    mode = "600";
    # Copy the decrypted key instead of symlinking. Some SSH clients and
    # permission checks do not follow symlinks reliably for private keys.
    symlink = false;
  };
  home.file.".ssh/${name}.pub".source = "${inputs.secrets}/ssh/${host}/${name}.pub";
}
