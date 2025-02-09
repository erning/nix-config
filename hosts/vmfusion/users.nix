{ settings, pkgs, ... }:

if settings.user != null then
  {
    users.users.${settings.user} = {
      isSystemUser = true;
      uid = 501; # same as macOS
      home = "/home/${settings.user}";
      homeMode = "700";
      group = "users";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      createHome = true;
      shell = pkgs.fish;
    };
  }
else
  { }
