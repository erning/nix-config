{
  config,
  lib,
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
  ];

  home.stateVersion = "25.05";

  features = lib.mkMerge [
    presets.workstation
    { nushell.enable = false; }
  ];
}
