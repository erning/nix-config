{
  config,
  lib,
  inputs,
  ...
}:

let
  cfg = config.features.yazi;
in
{
  options.features.yazi.enable = lib.mkEnableOption "yazi";

  config = lib.mkIf cfg.enable {
    programs.yazi = lib.mkIf cfg.enable {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    xdg.configFile = config.lib.dotfiles.configFiles [
      "yazi/theme.toml"
    ] // {
      "yazi/Catppuccin-mocha.tmTheme".source =
        "${inputs.self}/dotfiles/.config/yazi/Catppuccin-mocha.tmTheme";
    };
  };
}
