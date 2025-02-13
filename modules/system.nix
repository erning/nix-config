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
    ./nixpkgs-overlays.nix
    (if isDarwin then ./darwin.nix else ./nixos.nix)
    ./packages.nix
    ./secrets.nix
  ];

  # Enable alternative shell support in nix-darwin.
  programs.fish.enable = true;
  programs.bash.enable = true;
  programs.zsh.enable = true;

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
