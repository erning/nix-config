{ settings, pkgs, ... }:

if settings.user != null then
  {
    users.users.${settings.user} = {
      shell = pkgs.fish;
    };
  }
else
  { }
