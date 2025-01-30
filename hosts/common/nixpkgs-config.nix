{ lib, ... }:

{
  nixpkgs.config = with lib; {
    allowUnfree = mkDefault true;
    allowBroken = mkDefault true;
    allowInsecure = mkDefault false;
    allowUnsupportedSystem = mkDefault true;
  };
}
