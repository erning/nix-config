{
  lib,
  pkgs,
  settings,
  inputs,
  ...
}:

let
  isDarwin = builtins.match ".*-darwin" settings.system != null;
in
{
  imports = [
    ./nix-settings.nix
    ./nixpkgs-config.nix
    ./nixpkgs-overlays.nix
    (if isDarwin then ./darwin.nix else ./nixos.nix)
    ./packages.nix
    ./secrets.nix
  ];

  # shell
  environment.shells = with pkgs; [
    bashInteractive
    zsh
    fish
  ];

  # openssh
  services.openssh.enable = lib.mkDefault true;

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      "${inputs.secrets}/ssh/erning/dragon/id_ed25519.pub"
    ];
  };

  #
  networking.hostName = lib.mkDefault "${settings.host}";

  time.timeZone = lib.mkDefault "Asia/Shanghai";
}
