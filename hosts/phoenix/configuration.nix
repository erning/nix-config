{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.kernelParams = [ "consoleblank=30" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  programs.fish.enable = true;
  users.users.erning = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/erning";
    homeMode = "700";
    group = "users";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    createHome = true;
    shell = pkgs.fish;
  };
}
