{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.apple-t2
  ];

  # Cache for apple-t2
  nix.settings = {
    substituters = [ "https://cache.soopy.moe" ];
    trusted-substituters = [ "https://cache.soopy.moe" ];
    trusted-public-keys = [ "cache.soopy.moe-1:0RZVsQeR+GOh0VQI9rvnHz55nVXkFardDqfm4+afjPo=" ];
  };

  # WiFi/Bluetooth firmware from macOS
  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation (final: {
      name = "brcm-firmware";
      src = /etc/nixos/firmware/brcm;
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp ${final.src}/* "$out/lib/firmware/brcm"
      '';
    }))
  ];

  # Auto blank screen without X
  boot.kernelParams = [ "consoleblank=30" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # Try to disable sleep/suspend
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # User
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

  # Docker
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # GNOME Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";
  # services.printing.enable = true;
  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus = {
      engines = with pkgs.ibus-engines; [
        libpinyin
      ];
    };
  };

  # Prefer flatpak for most GUI applications
  services.flatpak.enable = true;

  # Remote access via RDP
  services.xrdp.enable = true;
  services.xrdp.defaultWindowManager = "gnome-session";

  #
  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  # services.tailscale.enable = true;
}
