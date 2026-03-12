{ config, pkgs, ... }:

let
  cfg-fonts = config.features.fonts;
  fonts = with pkgs.unstable; [
    libertinus
    jetbrains-mono
    newcomputermodern
    # stix-two
  ];
in
{
  home.packages = [ pkgs.typst ] ++ (if cfg-fonts.enable then fonts else [ ]);
}
