{ pkgs, ... }:

{
  system.primaryUser = "erning";

  programs.fish.enable = true;
  users.users.erning = {
    shell = pkgs.fish;
  };
}
