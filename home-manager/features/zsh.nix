{
  config,
  lib,
  ...
}:

let
  cfg = config.features.zsh;
in
{
  options.features.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf cfg.enable {
    programs.zsh = lib.mkIf cfg.enable {
      enable = true;
      dotDir = "${config.xdg.configHome}/zsh";
    };
  };
}
