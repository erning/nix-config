{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.zig;
in
{
  options.features.zig.enable = lib.mkEnableOption "zig";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      zig
    ];
  };
}
