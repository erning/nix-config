{ settings, config, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in
{
  programs.ssh = {
    enable = true;
    includes = [
      "conf.d/*.conf"
    ] ++ (if settings.isDarwin then [ "~/.orbstack/ssh/config" ] else [ ]);
    # userKnownHostsFile = "/dev/null";
    extraConfig = ''
      NoHostAuthenticationForLocalhost yes
      StrictHostKeyChecking no
    '';
  };

  home.file.".ssh/conf.d/homelab.conf".source = symlink ".ssh/conf.d/homelab.conf";
  home.file.".ssh/conf.d/vps.conf".source = symlink ".ssh/conf.d/vps.conf";
}
