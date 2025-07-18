{
  config,
  lib,
  pkgs,
  inputs,
  settings,
  ...
}:

let
  features = import "${inputs.self}/lib/features.nix" { inherit lib; };
  # ssh-key = (import "${inputs.self}/lib/ssh-key.nix" { inherit config inputs; }) settings.host;
  ssh-key =
    let
      host = settings.host;
    in
    name: {
      age.secrets."ssh/${host}/${name}" = {
        file = "${inputs.secrets}/ssh/${host}/${name}.age";
        path = "${config.home.homeDirectory}/.ssh/${name}";
        mode = "600";
        symlink = false; # Disable symbolic link creation. use copy instead.
      };
      home.file.".ssh/${name}.pub".source = "${inputs.secrets}/ssh/${host}/${name}.pub";
    };
in
{
  imports = [
    (ssh-key "id_ed25519")
    (ssh-key "id_rsa")
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/keys.txt"
  ];

  features = lib.mkMerge [
    features.console
    features.desktop
    features.develop
  ];

  home.packages = with pkgs; [
    ffmpeg
    yt-dlp
    postgresql
    mariadb-client
  ];
}
