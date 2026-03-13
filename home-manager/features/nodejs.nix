{ config, pkgs, ... }:
{
  _description = "Node.js and package managers";
  home.packages = with pkgs; [
    nodejs_24
    pnpm
    bun
  ];

  home.file = config.lib.dotfiles.homeFiles [
    ".npmrc"
  ];
}
