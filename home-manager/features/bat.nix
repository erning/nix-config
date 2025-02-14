{
  config,
  lib,
  ...
}:

let
  cfg = config.features.bat;
in
{
  options.features.bat.enable = lib.mkEnableOption "bat";

  config = lib.mkIf cfg.enable {
    programs.bat = lib.mkIf cfg.enable {
      enable = true;
      config = {
        theme = "Coldark-Dark";
        style = "plain";
        paging = "never";
      };
    };
  };
}
