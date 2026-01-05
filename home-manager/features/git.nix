{
  config,
  lib,
  pkgs,
  settings,
  inputs,
  ...
}:

let
  cfg = config.features.git;
  # Path to dotfiles directory (symlinked to ~/.dotfiles)
  dotfiles = "${config.home.homeDirectory}/.dotfiles";

  # Helper to create symlinks from dotfiles to config locations
  # mkOutOfStoreSymlink creates a symlink that points outside Nix store
  # This allows editing dotfiles directly without rebuilding
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";

  # Platform detection for conditional configuration
  isDarwin = builtins.match ".*-darwin" settings.system != null;
in
{
  options.features.git.enable = lib.mkEnableOption "git";

  config = lib.mkIf cfg.enable {
    # Install git and related tools
    home.packages = with pkgs; [
      git # Version control
      git-lfs # Git Large File Storage
      git-crypt # Encrypt git files using symmetric encryption
      delta # Better git diff viewer
      lazygit # Terminal UI for git
    ];

    # Configure git using multiple files
    xdg.configFile = {
      # Main git configuration file
      "git/config".source = symlink ".config/git/config";

      # macOS-specific git configuration (conditionally enabled)
      # Darwin has different credential helper and merge tool paths
      "git/darwin.gitconfig" = {
        enable = isDarwin;
        source = symlink ".config/git/darwin.gitconfig";
      };

      # Catppuccin theme for git (color scheme)
      "git/catppuccin.gitconfig".source = "${inputs.self}/dotfiles/.config/git/catppuccin.gitconfig";

      # Lazygit configuration (TUI settings)
      "lazygit/config.yml".source = symlink ".config/lazygit/config.yml";
    };
  };
}
