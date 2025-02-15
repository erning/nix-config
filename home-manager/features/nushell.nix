{
  config,
  lib,
  ...
}:

let
  cfg = config.features.nushell;
in
{
  options.features.nushell.enable = lib.mkEnableOption "nushell";

  config = lib.mkIf cfg.enable {
    programs.nushell = lib.mkIf cfg.enable {
      enable = true;
    };
  };
}
