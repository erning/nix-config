{
  imports = [
    ./base.nix
    ./fonts/nerdfont.nix
    ./fonts/lxgw.nix
  ];

  xdg.configFile."zed" = {
    source = ../dotfiles/.config/zed;
    recursive = true;
  };

  xdg.configFile."alacritty" = {
    source = ../dotfiles/.config/alacritty;
    recursive = true;
  };

  xdg.configFile."ghostty" = {
    source = ../dotfiles/.config/ghostty;
    recursive = true;
  };

  xdg.configFile."kitty" = {
    source = ../dotfiles/.config/kitty;
    recursive = true;
  };
}
