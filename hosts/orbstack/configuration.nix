{
  lib,
  pkgs,
  settings,
  ...
}:

{
  imports = lib.optional (builtins.pathExists "/etc/nixos/configuration.nix") "/etc/nixos/configuration.nix";

  networking.hostName = lib.mkForce "${settings.host}";

  programs.fish.enable = true;
  users.users.erning = {
    isNormalUser = true;
    shell = pkgs.fish;
  };

  # Minimal fallback config for flake check when external config is unavailable
  boot.isContainer = lib.mkDefault true;
}
