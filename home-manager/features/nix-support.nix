{ pkgs, settings, ... }:
{
  _description = "nix support";

  home.packages = with pkgs; [
    nil
    nixd
    (if settings.nixpkgsSeries == "25.05" then nixfmt-rfc-style else nixfmt)
  ];
}
