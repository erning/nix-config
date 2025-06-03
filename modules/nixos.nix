{ lib, ... }:

{
  system.stateVersion = "25.05";

  programs.fish.enable = true;
  programs.zsh.enable = true;

  #
  services.openssh.settings.PasswordAuthentication = lib.mkDefault true;
  services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";
  services.openssh.authorizedKeysInHomedir = lib.mkDefault true;

  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  #
  networking.firewall.enable = lib.mkDefault false;
  networking.networkmanager.enable = lib.mkDefault true;

  #
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  i18n.extraLocaleSettings = lib.mkDefault {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
}
