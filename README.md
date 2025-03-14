# README

```
$ git clone git@github.com:erning/nix-config.git

$ cd nix-config
$ darwin-rebuild switch --flake .#dragon

$ ln -s "$(pwd)/dotfiles" ~/.dotfiles
$ nix run home-manager -- switch --flake .#erning@dragon
```

## dev shell with nix flakes

Example:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, ... }@inputs:
    let
      nixpkgs = inputs.nixpkgs;
      flake-utils = inputs.flake-utils;
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      with pkgs;
      {
        devShells.default = mkShell {
          nativeBuildInputs = [ pkg-config ];
          buildInputs = [ openssl ];
        };
      }
    );
}
```

add `use flake` to `.envrc`
