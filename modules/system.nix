{
  lib,
  pkgs,
  settings,
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

  environment.variables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # openssh
  services.openssh.enable = lib.mkDefault true;

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEtSVQmMAV9fgSl57vllhUhxAb1OLOgS0Aui8d2n/oYm erning@dragon"
    ];
  };

  #
  networking.hostName = lib.mkDefault "${settings.host}";

  time.timeZone = lib.mkDefault "Asia/Shanghai";
}
