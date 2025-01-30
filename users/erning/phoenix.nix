{
  settings,
  config,
  inputs,
  ...
}:

let
  key.name = "id_ed25519";
  key.file = "ssh/${settings.user}/${settings.host}/${key.name}";
in
{
  imports = [
    ../../home/linux-console.nix
  ];

  age.secrets."${key.file}" = {
    file = "${inputs.secrets}/${key.file}.age";
    path = "${config.home.homeDirectory}/.ssh/${key.name}";
    mode = "600";
  };
  home.file.".ssh/${key.name}.pub".source = "${inputs.secrets}/${key.file}.pub";

  # home.file.".ssh/authorized_keys" = {
  #   text = lib.concatStringsSep "\n" [
  #     (builtins.builtins.readFile ../../secrets/ssh/erning/dragon/id_ed25519.pub)
  #     (builtins.builtins.readFile ../../secrets/ssh/erning/phoenix/id_ed25519.pub)
  #     (builtins.builtins.readFile ../../secrets/ssh/erning/blink/id_ed25519.pub)
  #     (builtins.builtins.readFile ../../secrets/ssh/erning/pineapple/id_ed25519.pub)
  #     (builtins.builtins.readFile ../../secrets/ssh/erning/mango/id_ed25519.pub)
  #     (builtins.builtins.readFile ../../secrets/ssh/erning/vm/id_ed25519.pub)
  #   ];
  # };
}
