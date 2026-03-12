{
  config,
  lib,
  inputs,
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
    };

    xdg.configFile = config.lib.dotfiles.configFiles [
      "bat/config"
    ] // {
      "bat/themes" = {
        source = "${inputs.self}/dotfiles/.config/bat/themes";
        recursive = true;
      };
    };
  };
}
