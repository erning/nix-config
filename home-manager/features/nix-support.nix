{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.nix-support;
in
{
  options.features.nix-support.enable = lib.mkEnableOption "nix support";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nil
      nixd
      nixfmt-rfc-style
    ];
  };
}
