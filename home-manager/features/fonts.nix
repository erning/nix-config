{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.fonts;
in
{
  options.features.fonts.enable = lib.mkEnableOption "fonts";

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;

    # pkgs = inputs.nixpkgs-unstable.legacyPackages.${settings.system};
    home.packages = with pkgs.unstable; [
      lxgw-wenkai
      lxgw-neoxihei
      nerd-fonts.jetbrains-mono
      nerd-fonts._0xproto
      font-awesome
      nerd-fonts.symbols-only
    ];
  };
}
