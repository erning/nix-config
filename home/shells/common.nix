{ pkgs, ... }:

{
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

  xdg.configFile."starship.toml".source = ../../dotfiles/.config/starship.toml;
}
