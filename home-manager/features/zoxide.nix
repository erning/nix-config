{
  config,
  lib,
  ...
}:

let
  cfg = config.features.zoxide;
in
{
  options.features.zoxide.enable = lib.mkEnableOption "zoxide";

  config = lib.mkIf cfg.enable {
    programs.zoxide = lib.mkIf cfg.enable {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };
  };
}
