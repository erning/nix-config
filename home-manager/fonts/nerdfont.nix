{ pkgs, ... }:

{
  # pkgs = inputs.nixpkgs-unstable.legacyPackages.${settings.system};
  home.packages = with pkgs.unstable; [
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
  ];
}
