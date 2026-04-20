{ pkgs, config, ... }:

let
  neovide-multi = pkgs.writeShellScriptBin "neovide-multi" ''
    case "$(basename "$0")" in
      lazyvide) export NVIM_APPNAME=nvim-lazyvim ;;
    esac
    exec ${pkgs.neovide}/bin/neovide "$@"
  '';

  neovide-profiles = pkgs.runCommand "neovide-profiles" { } ''
    mkdir -p $out/bin
    ln -s ${neovide-multi}/bin/neovide-multi $out/bin/lazyvide
  '';
in
{
  _description = "Neovide GUI for Neovim (LazyVim)";

  features.neovim.enable = true;

  home.packages = [
    pkgs.neovide
    neovide-profiles
  ];

  xdg.configFile = config.lib.dotfiles.configDir "neovide";

  programs.fish.shellAliases.vide = "lazyvide";
  programs.bash.shellAliases.vide = "lazyvide";
  programs.zsh.shellAliases.vide = "lazyvide";
}
