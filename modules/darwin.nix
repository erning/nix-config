{ lib, settings, ... }:

{
  system.stateVersion = 6;

  programs.fish.enable = true;
  programs.bash.enable = true;
  programs.zsh.enable = true;

  networking.computerName = lib.mkDefault "${settings.host}";
  system.defaults.smb.NetBIOSName = lib.mkDefault "${settings.host}";

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

  # The `system.activationScripts.postUserActivation` option has
  #       been removed
  # system.activationScripts.postUserActivation.text = ''
  #   # activateSettings -u will reload the settings from the database and apply them to the current session,
  #   # so we do not need to logout and login again to make the changes take effect.
  #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  # '';
}
