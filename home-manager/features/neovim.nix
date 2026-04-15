{ pkgs, config, ... }:

let
  nvim-multi = pkgs.writeShellScriptBin "nvim-multi" ''
    case "$(basename "$0")" in
      lazyvim) export NVIM_APPNAME=nvim-lazyvim ;;
    esac
    exec ${pkgs.neovim}/bin/nvim "$@"
  '';

  nvim-profiles = pkgs.runCommand "nvim-profiles" { } ''
    mkdir -p $out/bin
    ln -s ${nvim-multi}/bin/nvim-multi $out/bin/lazyvim
  '';
in
{
  _description = "Neovim editor (LazyVim)";

  home.packages = [
    pkgs.neovim
    nvim-profiles
  ];

  xdg.configFile = config.lib.dotfiles.configDir "nvim-lazyvim";

  home.sessionVariables = {
    EDITOR = "lazyvim";
    VISUAL = "lazyvim";
  };

  programs.fish.shellAliases.vi = "lazyvim";
  programs.bash.shellAliases.vi = "lazyvim";
  programs.zsh.shellAliases.vi = "lazyvim";
}
