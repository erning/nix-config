# README

```
$ git clone git@github.com:erning/nix-config.git

$ cd nix-config
$ darwin-rebuild switch --flake .#dragon

$ ln -s "$(pwd)/dotfiles" ~/.dotfiles
$ nix run home-manager -- switch --flake .#erning@dragon
```