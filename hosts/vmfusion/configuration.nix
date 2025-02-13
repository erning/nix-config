{ pkgs, inputs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.vmware.guest.enable = true;

  programs.fish.enable = true;
  users.users.erning = {
    isSystemUser = true;
    uid = 501; # same as macOS
    home = "/home/erning";
    homeMode = "700";
    group = "users";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    createHome = true;
    shell = pkgs.fish;

    openssh.authorizedKeys.keyFiles = [
      "${inputs.secrets}/ssh/erning/dragon/id_ed25519.pub"
      "${inputs.secrets}/ssh/erning/phoenix/id_ed25519.pub"
      "${inputs.secrets}/ssh/erning/blink/id_ed25519.pub"
      "${inputs.secrets}/ssh/erning/pineapple/id_ed25519.pub"
      "${inputs.secrets}/ssh/erning/mango/id_ed25519.pub"
      "${inputs.secrets}/ssh/erning/vm/id_ed25519.pub"
    ];
  };
}
