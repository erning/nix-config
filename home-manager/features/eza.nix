{
  config,
  lib,
  ...
}:

let
  cfg = config.features.eza;
in
{
  options.features.eza.enable = lib.mkEnableOption "eza";

  config = lib.mkIf cfg.enable {
    programs.eza = lib.mkIf cfg.enable {
      enable = true;
      git = true;
      icons = "auto";
    };
  };
}
