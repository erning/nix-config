{
  lib,
  pkgs,
  settings,
  ...
}:

{
  imports = [ "/etc/nixos/configuration.nix" ];

  networking.hostName = lib.mkForce "${settings.host}";

  programs.fish.enable = true;
  users.users.erning = {
    shell = pkgs.fish;
  };

}
