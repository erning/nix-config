{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.go;
in
{
  options.features.go.enable = lib.mkEnableOption "go";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      go
    ];
    programs.go.enable = true;
    programs.go.goPath = ".go";
  };
}
