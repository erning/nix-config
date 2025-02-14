{ lib, ... }:

{
  imports = [
    ./build-essential.nix
    ./direnv.nix
    ./fonts.nix
    ./git.nix
    ./neovim.nix
    ./nix-support.nix
    ./python.nix
    ./rustup.nix
    ./shell.nix
    ./ssh.nix
    ./tmux.nix
    ./vim.nix
    ./zig.nix
  ];

  features = {
    shell.enable = lib.mkDefault true;
    shell.fish.enable = lib.mkDefault true;
    shell.bash.enable = lib.mkDefault true;
    shell.zsh.enable = lib.mkDefault true;

    vim.enable = lib.mkDefault true;
    git.enable = lib.mkDefault true;
    tmux.enable = lib.mkDefault false;
    neovim.enable = lib.mkDefault false;

    ssh.enable = lib.mkDefault true;

    build-essential.enable = lib.mkDefault false;
    nix-support.enable = lib.mkDefault false;
    rustup.enable = lib.mkDefault false;
    zig.enable = lib.mkDefault false;
    python.enable = lib.mkDefault false;

    direnv.enable = lib.mkDefault false;
  };
}
