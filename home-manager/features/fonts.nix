{ pkgs, ... }:
{
  _description = "common fonts";
  fonts.fontconfig.enable = true;

  home.packages = with pkgs.unstable; [
    libertine
    lxgw-wenkai
    lxgw-neoxihei
    nerd-fonts.jetbrains-mono
    nerd-fonts._0xproto
    font-awesome
    nerd-fonts.symbols-only
  ];
}
