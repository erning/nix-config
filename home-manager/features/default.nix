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
}
