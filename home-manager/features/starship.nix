{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.starship;
in
{
  options.features.starship.enable = lib.mkEnableOption "starship";

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = pkgs.unstable.starship;
    };

    xdg.configFile = config.lib.dotfiles.configFiles [
      "starship.toml"
    ];
  };
}
