{
  config,
  lib,
  ...
}:

let
  cfg = config.features.fish;
in
{
  options.features.fish.enable = lib.mkEnableOption "fish";

  config = lib.mkIf cfg.enable {
    programs.fish = lib.mkIf cfg.enable {
      enable = true;
    };
  };
}
