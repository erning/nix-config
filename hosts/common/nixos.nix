{
  settings,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  system.stateVersion = "24.11";

  # shell
  programs.fish.enable = true;
  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  # openssh
  services.openssh.enable = lib.mkDefault true; # /etc/nixos/orbstack.nix
  # services.openssh.settings.PasswordAuthentication = lib.mkDefault true;
  # services.openssh.settings.PermitRootLogin = lib.mkDefault "yes";

  security.sudo.wheelNeedsPassword = false;
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      "${inputs.secrets}/ssh/erning/dragon/id_ed25519.pub"
    ];
  };

  #
  networking.firewall.enable = lib.mkDefault false;
  networking.hostName = lib.mkDefault "${settings.host}";
  networking.networkmanager.enable = true;

  #
  time.timeZone = lib.mkDefault "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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
