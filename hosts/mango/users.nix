{ settings, pkgs, ... }:

if builtins.hasAttr "user" settings then
  {
    users.users.${settings.user} = {
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
