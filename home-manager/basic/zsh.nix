{
  programs.zsh = {
    enable = true;
    initExtra = ''
      path=("$HOME/.local/bin" $path)
    '';
  };
}
