{ lib, ... }:
{
  _description = "mise tool shims on PATH";

  home.sessionPath = lib.mkOrder 610 [
    "$HOME/.local/share/mise/shims"
  ];
}
