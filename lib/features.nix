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
    direnv.enable = true;
  } // base;

  desktop = {
    fonts.enable = true;
  };
in
{
  inherit base;
  inherit develop;
  inherit desktop;
}
