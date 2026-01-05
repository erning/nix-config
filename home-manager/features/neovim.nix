{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.features.neovim;

  # Define custom editor wrapper that sets NVIM_APPNAME environment variable
  # This allows neovim to use a separate config directory (nvim-lazyvim)
  # while still sharing the same binary. The wrapper is just running nvim
  # with the NVIM_APPNAME environment variable set.
  lazyvim = "NVIM_APPNAME=nvim-lazyvim nvim";
in
{
  options.features.neovim.enable = lib.mkEnableOption "neovim";

  config = lib.mkIf cfg.enable {
    # Install neovim package
    home.packages = with pkgs; [
      neovim
    ];

    # Copy entire LazyVim configuration directory to XDG config
    # recursive=true ensures all subdirectories and files are copied
    # LazyVim config is stored in dotfiles/.config/nvim-lazyvim
    xdg.configFile."nvim-lazyvim" = {
      source = "${inputs.self}/dotfiles/.config/nvim-lazyvim";
      recursive = true;
    };

    # Copy lazyvim wrapper script to ~/.local/bin
    # This script is what gets called when you run "lazyvim" or "vi"
    home.file.".local/bin/lazyvim" = {
      source = "${inputs.self}/dotfiles/.local/bin/lazyvim";
    };

    # Set default editor to use the lazyvim wrapper
    # This makes $EDITOR and $VISUAL use our custom config
    home.sessionVariables = {
      "EDITOR" = "lazyvim";
      "VISUAL" = "lazyvim";
    };

    # Create shell aliases for 'vi' to use lazyvim
    # Applies to fish, bash, and zsh shells
    programs.fish.shellAliases.vi = "${lazyvim}";
    programs.bash.shellAliases.vi = "${lazyvim}";
    programs.zsh.shellAliases.vi = "${lazyvim}";
  };
}
