{
  config,
  lib,
  pkgs,
  ...
}:

{
  _description = "Typst document typesetter";
  home.packages = [
    pkgs.typst
  ]
  ++ lib.optionals config.features.fonts.enable (
    with pkgs.unstable;
    [
      libertinus
      jetbrains-mono
      newcomputermodern
    ]
  );
}
