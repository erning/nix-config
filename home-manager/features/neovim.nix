{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.neovim;
  lazyvim = "NVIM_APPNAME=nvim-lazyvim nvim";
in
{
  options.features.neovim.enable = lib.mkEnableOption "neovim";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      neovim
    ];

    xdg.configFile = {
      "nvim-lazyvim" = {
        source = ../../dotfiles/.config/nvim-lazyvim;
        recursive = true;
      };
    };

    programs.fish.shellAliases.vi = "${lazyvim}";
    programs.bash.shellAliases.vi = "${lazyvim}";
    programs.zsh.shellAliases.vi = "${lazyvim}";
  };
}
