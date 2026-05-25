{
  config,
  lib,
  settings,
  options,
  ...
}:

{
  _description = "SSH client";
  programs.ssh = {
    enable = true;

    includes = [
      "conf.d/*.conf"
    ]
    ++ (if settings.isDarwin then [ "~/.orbstack/ssh/config" ] else [ ]);

    # userKnownHostsFile = "/dev/null";
    extraConfig = ''
      NoHostAuthenticationForLocalhost yes
      StrictHostKeyChecking no
    '';
  }
  // lib.optionalAttrs (options.programs.ssh ? settings) {
    settings."*" = { };
  }
  // lib.optionalAttrs (!(options.programs.ssh ? settings)) {
    matchBlocks."*" = { };
  }
  // lib.optionalAttrs (options.programs.ssh ? enableDefaultConfig) {
    enableDefaultConfig = false;
  };

  home.file = config.lib.dotfiles.homeFiles [
    ".ssh/authorized_keys"
    ".ssh/conf.d/homelab.conf"
    ".ssh/conf.d/vps.conf"
  ];
}
