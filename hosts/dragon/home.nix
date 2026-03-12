{
  config,
  lib,
  pkgs,
  inputs,
  settings,
  ...
}:

let
  presets = import "${inputs.self}/home-manager/presets.nix" { inherit lib; };
  ssh-key = (import "${inputs.self}/lib/ssh-key.nix" { inherit config inputs; }) settings.host;
in
{
  imports = [
    (ssh-key "id_ed25519")
    (ssh-key "id_rsa")
  ];

  features = lib.mkMerge [
    presets.workstation
  ];

  home.packages = with pkgs; [
    postgresql
    mariadb.client
  ];
}
