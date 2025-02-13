{
  config,
  inputs,
  settings,
  ...
}:

let
  ssh-key =
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
    };
in
{
  config = {
    features = {
      tmux.enable = true;
      neovim.enable = true;

      build-essential.enable = true;
      nix-support.enable = true;
      rustup.enable = true;
      zig.enable = true;
    };
  } // (ssh-key { });
}
