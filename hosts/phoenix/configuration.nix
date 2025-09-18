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

  services.tailscale.enable = true;

  # Known issues:
  #      - CVE-2019-9501: heap buffer overflow, potentially allowing remote code execution by sending specially-crafted WiFi packets
  #      - CVE-2019-9502: heap buffer overflow, potentially allowing remote code execution by sending specially-crafted WiFi packets
  #      - The Broadcom STA wireless driver is not maintained and is incompatible with Linux kernel security mitigations. It is heavily recommended to replace the hardware and remove the driver. Proceed at your own risk!
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-57-6.12.47"
  ];
}
