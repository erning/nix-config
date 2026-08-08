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

  targets.genericLinux.enable = true;

  features = lib.mkMerge [
    presets.workstation
    {
      homebrew.enable = true;
      nushell.enable = false;
    }
  ];
}
