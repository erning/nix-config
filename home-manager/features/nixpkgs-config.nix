{ config, lib, ... }:

let
  cfg = config.features.nixpkgs-config;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.nixpkgs-config.enable = lib.mkEnableOption "nixpkgs-config";
  config = lib.mkIf cfg.enable {
    xdg.configFile."nixpkgs/config.nix".source = symlink ".config/nixpkgs/config.nix";
  };
}
