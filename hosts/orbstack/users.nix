{ settings, pkgs, ... }:

if builtins.hasAttr "user" settings then
  {
    users.users.${settings.user} = {
      shell = pkgs.fish;
    };
  }
else
  { }
