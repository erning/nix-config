{ lib, settings, ... }:

{
  system.stateVersion = 6;

  programs.fish.enable = true;
  programs.bash.enable = true;
  programs.zsh.enable = true;

  # Preserve Ghostty terminfo env through sudo so TERM=xterm-ghostty
  # keeps working in elevated shells.
  security.sudo.extraConfig = ''
    Defaults env_keep += "TERMINFO TERMINFO_DIRS"
  '';

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
}
