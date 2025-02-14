{ inputs, ... }:

let
  scanFiles = import "${inputs.self}/lib/scan-files.nix";
in
{
  imports = (scanFiles ./.);
  #   ./bash.nix
  #   ./bat.nix
  #   ./build-essential.nix
  #   ./direnv.nix
  #   ./eza.nix
  #   ./fish.nix
  #   ./fonts.nix
  #   ./fzf.nix
  #   ./git.nix
  #   ./neovim.nix
  #   ./nix-support.nix
  #   ./python.nix
  #   ./rustup.nix
  #   ./ssh.nix
  #   ./starship.nix
  #   ./tmux.nix
  #   ./vim.nix
  #   ./zig.nix
  #   ./zsh.nix
  # ];
}
