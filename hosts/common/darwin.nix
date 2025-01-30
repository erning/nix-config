{
  settings,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nix.useDaemon = true;

  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;
  programs.bash.enable = true;
  programs.zsh.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  # openssh
  services.openssh.enable = lib.mkDefault true; # /etc/nixos/orbstack.nix
  # services.openssh.settings.PasswordAuthentication = lib.mkDefault true;
  # services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      "${inputs.secrets}/ssh/erning/dragon/id_ed25519.pub"
    ];
  };

  #
  networking.hostName = lib.mkDefault "${settings.host}";
  networking.computerName = lib.mkDefault "${settings.host}";
  system.defaults.smb.NetBIOSName = lib.mkDefault "${settings.host}";

  #
  #
  #

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  system.defaults.trackpad = {
    Clicking = lib.mkDefault true;
    Dragging = lib.mkDefault true;
  };

  system.defaults.dock = {
    autohide = lib.mkDefault true;
    show-recents = lib.mkDefault false;
  };

  system.keyboard = {
    enableKeyMapping = lib.mkDefault true;
    remapCapsLockToControl = lib.mkDefault true;
  };

  system.activationScripts.postUserActivation.text = ''
    # activateSettings -u will reload the settings from the database and apply them to the current session,
    # so we do not need to logout and login again to make the changes take effect.
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
