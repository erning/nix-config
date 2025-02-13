{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.shell;

  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  symlink = file: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${file}";
in

{
  options.features.shell = {
    enable = lib.mkEnableOption "shell";
    fish.enable = lib.mkEnableOption "shell - fish";
    bash.enable = lib.mkEnableOption "shell - bash";
    zsh.enable = lib.mkEnableOption "shell - zsh";
  };

  config = lib.mkIf cfg.enable {

    programs.fish = lib.mkIf cfg.fish.enable {
      enable = true;
      interactiveShellInit = ''
        if not contains "$HOME/.local/bin" $PATH
            set -x PATH "$HOME/.local/bin" $PATH
        end
      '';
    };

    programs.bash = lib.mkIf cfg.bash.enable {
      enable = true;
      initExtra = ''
        export PATH="$HOME/.local/bin:$PATH"
      '';
    };

    programs.zsh = lib.mkIf cfg.zsh.enable {
      enable = true;
      initExtra = ''
        path=("$HOME/.local/bin" $path)
      '';
    };

    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };

    programs.bat = {
      enable = true;
      config = {
        theme = "Coldark-Dark";
        style = "plain";
        paging = "never";
      };
    };

    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      package = pkgs.unstable.starship;
    };

    xdg.configFile."starship.toml".source = symlink ".config/starship.toml";
  };
}
