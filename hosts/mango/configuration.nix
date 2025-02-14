{ pkgs, ... }:

{
  programs.fish.enable = true;
  users.users.erning = {
    shell = pkgs.fish;
  };
}
