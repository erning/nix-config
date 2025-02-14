{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.python;
in
{
  options.features.python.enable = lib.mkEnableOption "python";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      python3
      python3Packages.uv
    ];
  };
}
