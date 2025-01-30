{
  imports = [
    ./shells/common.nix
    ./shells/fish.nix
    ./shells/bash.nix
    ./shells/zsh.nix
    ./shells/tmux.nix

    ./ssh/openssh.nix

    ./editors/vim.nix
    ./editors/neovim.nix

    ./develop/git.nix
    ./develop/rust/rustup.nix
    ./develop/nix/nix-support.nix
    ./develop/just.nix
    ./develop/direnv.nix
    #./develop/devenv.nix
  ];
}
