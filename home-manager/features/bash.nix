{
  config,
  lib,
  ...
}:

let
  cfg = config.features.bash;
in
{
  options.features.bash.enable = lib.mkEnableOption "bash";

  config = lib.mkIf cfg.enable {
    programs.bash = lib.mkIf cfg.enable {
      enable = true;
    };
  };
}
