let
  base = {
    shell.enable = true;
    shell.fish.enable = true;
    shell.bash.enable = true;
    shell.zsh.enable = true;

    vim.enable = true;
    git.enable = true;
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
