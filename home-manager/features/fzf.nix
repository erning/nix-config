{
  config,
  lib,
  ...
}:

let
  cfg = config.features.fzf;
in
{
  options.features.fzf.enable = lib.mkEnableOption "fzf";

  config = lib.mkIf cfg.enable {
    programs.fzf = lib.mkIf cfg.enable {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
  };
}
