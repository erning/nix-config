{ settings, pkgs, ... }:

if builtins.hasAttr "user" settings then
  {
    users.users.${settings.user} = {
      isNormalUser = true;
      uid = 1000;
      home = "/home/${settings.user}";
      homeMode = "700";
      group = "users";
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
      createHome = true;
      shell = pkgs.fish;

      openssh.authorizedKeys.keyFiles = [
        ../../secrets/ssh/erning/dragon/id_ed25519.pub
        ../../secrets/ssh/erning/phoenix/id_ed25519.pub
        ../../secrets/ssh/erning/blink/id_ed25519.pub
        ../../secrets/ssh/erning/pineapple/id_ed25519.pub
        ../../secrets/ssh/erning/mango/id_ed25519.pub
        ../../secrets/ssh/erning/vm/id_ed25519.pub
      ];
    };
  }
else
  { }
