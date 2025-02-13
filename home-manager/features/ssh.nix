{
  config,
  lib,
  pkgs,
  settings,
  ...
}:

let
  cfg = config.features.ssh;
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
  isDarwin = builtins.match ".*-darwin" settings.system != null;
in
{
  options.features.ssh.enable = lib.mkEnableOption "ssh";

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      includes = [
        "conf.d/*.conf"
      ] ++ (if isDarwin then [ "~/.orbstack/ssh/config" ] else [ ]);
      # userKnownHostsFile = "/dev/null";
      extraConfig = ''
        NoHostAuthenticationForLocalhost yes
        StrictHostKeyChecking no
      '';
    };

    home.file.".ssh/conf.d/homelab.conf".source = symlink ".ssh/conf.d/homelab.conf";
    home.file.".ssh/conf.d/vps.conf".source = symlink ".ssh/conf.d/vps.conf";
  };
}
