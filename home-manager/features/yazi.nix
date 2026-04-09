{ config, inputs, ... }:
{
  _description = "Yazi file manager";
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  xdg.configFile =
    config.lib.dotfiles.configFiles [
      "yazi/theme.toml"
    ]
    // {
      "yazi/Catppuccin-mocha.tmTheme".source =
        "${inputs.self}/dotfiles/.config/yazi/Catppuccin-mocha.tmTheme";
    };
}
