{ config, lib, settings, options, ... }:

let
  isDarwin = builtins.match ".*-darwin" settings.system != null;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks."*" = { };

    includes = [
      "conf.d/*.conf"
    ]
    ++ (if isDarwin then [ "~/.orbstack/ssh/config" ] else [ ]);

    # userKnownHostsFile = "/dev/null";
    extraConfig = ''
      NoHostAuthenticationForLocalhost yes
      StrictHostKeyChecking no
    '';
  } // lib.optionalAttrs (options.programs.ssh ? enableDefaultConfig) {
    enableDefaultConfig = false;
  };

  home.file = config.lib.dotfiles.homeFiles [
    ".ssh/authorized_keys"
    ".ssh/conf.d/homelab.conf"
    ".ssh/conf.d/vps.conf"
  ];
}
