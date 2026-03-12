{
  config,
  lib,
  inputs,
  ...
}:

let
  presets = import "${inputs.self}/home-manager/presets.nix" { inherit lib; };
in
{
  age.secrets."ssh/vm/id_ed25519" = {
    file = "${inputs.secrets}/ssh/vm/id_ed25519.age";
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "600";
  };
  home.file.".ssh/id_ed25519.pub".source = "${inputs.secrets}/ssh/vm/id_ed25519.pub";

  features = lib.mkMerge [
    presets.workstation
  ];
}
