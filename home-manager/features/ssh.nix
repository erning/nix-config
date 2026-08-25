{
  config,
  ...
}:

{
  _description = "SSH client configuration";
  home.file = config.lib.dotfiles.homeFiles [
    ".ssh/config"
    ".ssh/authorized_keys"
    ".ssh/conf.d/10-homelab.conf"
    ".ssh/conf.d/20-vps.conf"
    ".ssh/conf.d/90-orbstack.conf"
  ];
}
