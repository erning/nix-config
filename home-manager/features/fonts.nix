{ pkgs, ... }:

{
  # pkgs = inputs.nixpkgs-unstable.legacyPackages.${settings.system};
  home.packages = with pkgs.unstable; [
    lxgw-wenkai
    lxgw-neoxihei
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
  ];
}
