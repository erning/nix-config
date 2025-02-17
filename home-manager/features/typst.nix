{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.typst;
in
{
  options.features.typst.enable = lib.mkEnableOption "typst";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      typst
      # fonts
      libertinus
      jetbrains-mono
      newcomputermodern
      # stix-two
    ];
  };
}
