{ pkgs, config, ... }:

let
  cceSrc = pkgs.fetchFromGitHub {
    owner = "erning";
    repo = "cce";
    rev = "v2.1.6";
    hash = "sha256-1tuB/J5juEjSa0BwmtTb3DxsXom6vIf+VZU5s+XZ8dc=";
  };

  cce = pkgs.runCommand "cce" { } ''
    mkdir -p $out/bin
    install -m755 ${cceSrc}/cce.sh $out/bin/cce
    patchShebangs $out/bin/cce
  '';
in
{
  _description = "Claude Code CLI";

  home.packages = [ cce ];

  xdg.configFile = config.lib.dotfiles.configFiles [
    "cce/kimi.env"
    "cce/minimax.env"
    "cce/zhipu.env"
  ];
}
