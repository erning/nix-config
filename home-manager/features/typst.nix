{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.typst;
  cfg-fonts = config.features.fonts;
  fonts = with pkgs.unstable; [
    libertinus
    jetbrains-mono
    newcomputermodern
    # stix-two
  ];
in
{
  options.features.typst.enable = lib.mkEnableOption "typst";

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.typst ] ++ (if cfg-fonts.enable then fonts else [ ]);
  };
}
