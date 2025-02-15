let
  base = {
    fish.enable = true;
    bash.enable = true;
    zsh.enable = true;
    starship.enable = true;
    eza.enable = true;
    fzf.enable = true;
    bat.enable = true;

    vim.enable = true;
    git.enable = true;

    ssh.enable = true;
  };

  develop = {
    tmux.enable = true;
    neovim.enable = true;

    build-essential.enable = true;
    nix-support.enable = true;
    rustup.enable = true;
    zig.enable = true;
    python.enable = true;
    go.enable = true;

    just.enable = true;
    direnv.enable = true;
  } // base;

  console = {
    tmux.enable = true;
    neovim.enable = true;
    nushell.enable = true;
    zellij.enable = true;
    zoxide.enable = true;
    yazi.enable = true;
  } // base;

  desktop = {
    fonts.enable = true;
    zed.enable = true;
    ghostty.enable = true;
    kitty.enable = true;
    alacritty.enable = true;
  } // base;
in
{
  inherit base;
  inherit develop;
  inherit console;
  inherit desktop;
}
