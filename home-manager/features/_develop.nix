{
  imports = [
    ./_basic.nix
    ./neovim.nix

    ./build-essential.nix
    ./rustup.nix
    ./nix.nix
    ./zig.nix
    ./go.nix

    ./direnv.nix
  ];
}
