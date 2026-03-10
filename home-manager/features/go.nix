{
  config,
  lib,
  pkgs,
  options,
  ...
}:

let
  cfg = config.features.go;
in
{
  options.features.go.enable = lib.mkEnableOption "go";

  config = lib.mkIf cfg.enable ({
    home.packages = with pkgs; [
      go
    ];
    programs.go.enable = true;
  } // lib.optionalAttrs (options.programs.go ? env) {
    programs.go.env = {
      GOPATH = ".go";
    };
  });
}
