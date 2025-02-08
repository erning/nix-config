{
  settings,
  pkgs,
  inputs,
  ...
}:

if builtins.hasAttr "user" settings then
  {
    users.users.${settings.user} = {
      shell = pkgs.fish;

      openssh.authorizedKeys.keyFiles = [
        "${inputs.secrets}/ssh/erning/dragon/id_ed25519.pub"
        "${inputs.secrets}/ssh/erning/phoenix/id_ed25519.pub"
        "${inputs.secrets}/ssh/erning/blink/id_ed25519.pub"
        "${inputs.secrets}/ssh/erning/pineapple/id_ed25519.pub"
        "${inputs.secrets}/ssh/erning/mango/id_ed25519.pub"
        "${inputs.secrets}/ssh/erning/vm/id_ed25519.pub"
      ];
    };
  }
else
  { }
