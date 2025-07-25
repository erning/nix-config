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
  ssh-key = (import "${inputs.self}/lib/ssh-key.nix" { inherit config inputs; }) settings.host;
in
{
  imports = [
    (ssh-key "id_ed25519")
  ];

  features = lib.mkMerge [
    features.console
    features.develop
    { fonts.enable = true; }
  ];

  home.packages = with pkgs; [
    postgresql
    mariadb-client
  ];
}
