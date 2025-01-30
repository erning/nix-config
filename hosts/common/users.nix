{ settings, inputs, ... }:

if builtins.hasAttr "user" settings then
  {
    users.users.${settings.user} = {
      home = (if settings.isDarwin then "/Users" else "/home") + "/${settings.user}";
      useDefaultShell = true;

      openssh.authorizedKeys.keyFiles = [
        "${inputs.secrets}/ssh/erning/dragon/id_ed25519.pub"
      ];
    };
  }
else
  { }
