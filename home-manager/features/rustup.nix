#
# $ rustup default stable
# $ rustup component add rust-analyzer
#

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.rustup;
in
{
  options.features.rustup.enable = lib.mkEnableOption "rustup";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      rustup
    ];
  };
}
