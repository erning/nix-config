{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.nodejs;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  options.features.nodejs.enable = lib.mkEnableOption "nodejs";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodejs
      pnpm
      bun
    ];

    home.file.".npmrc".source = symlink ".npmrc";
  };
}
