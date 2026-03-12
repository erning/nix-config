# Library Utilities

Core utility functions for building NixOS/nix-darwin system and home-manager configurations.

## mkSystem.nix

Creates system configurations for both Darwin and NixOS using a unified interface. Detects platform via `builtins.match ".*-darwin"` and calls `darwinSystem` or `nixosSystem` accordingly.

Imports `modules/system.nix` then `hosts/<host>/configuration.nix`. Passes a `settings` attrset (`{ host, system }`) to modules via `specialArgs`.

```nix
darwinConfigurations.dragon = mkSystem {
  host = "dragon";
  system = "aarch64-darwin";
};
```

Legacy macOS hosts use a pinned variant (`mkSystem-2505`) that substitutes `nixpkgs-2505` and `nix-darwin-2505` inputs into the same builder.

---

## mkHome.nix

Creates home-manager configurations for user environments. Passes a `settings` attrset (`{ user, host, system }`) to modules via `extraSpecialArgs`.

Imports `modules/nixpkgs-config.nix`, `modules/nixpkgs-overlays.nix`, `home-manager/home.nix`, then `hosts/<host>/home.nix`.

```nix
homeConfigurations."erning@dragon" = mkHome {
  user = "erning";
  host = "dragon";
  system = "aarch64-darwin";
};
```

Legacy macOS hosts use `mkHome-2505` (same pattern as mkSystem). Feature modules that use options not present in all home-manager versions must guard them with `lib.optionalAttrs (options.path ? attr) { ... }`.

---

## presets.nix

> Lives at `home-manager/presets.nix`, documented here for convenience.

Defines feature presets that enable groups of related tools. All values use `lib.mkDefault`.

**Building blocks** (non-overlapping):

| Preset | Purpose |
|--------|---------|
| `core` | shells, prompt, editors, git, ssh |
| `terminal` | neovim, tmux, nushell, zellij, yazi |
| `languages` | rustup, zig, python, go, nodejs, jdk, kotlin |
| `devtools` | nix-support, direnv, just, gradle, docker, claude-code |
| `graphical` | fonts, GUI terminals, desktop apps |

**Composites** (self-contained):

| Composite | Composition |
|-----------|-------------|
| `development` | `core` + `terminal` + `languages` + `devtools` |
| `workstation` | `development` + `graphical` |

```nix
{ lib, inputs, ... }:
let
  presets = import "${inputs.self}/home-manager/presets.nix" { inherit lib; };
in
{
  features = lib.mkMerge [
    presets.workstation
  ];
}
```

---

## mkFeatureImports.nix

Recursively scans a directory for `.nix` files (skipping `default.nix`), derives feature names from paths, and wraps each file with `options.features.<name>.enable` + `lib.mkIf`. Feature files are pure config functions -- no boilerplate needed.

Name derivation: `direnv.nix` -> `"direnv"`, `fonts/source-han.nix` -> `"fonts.source-han"`.

Use `_description = "...";` in a feature's returned attrset to override the default `mkEnableOption` description.

```nix
# home-manager/features/default.nix
{ inputs, ... }:
let
  mkFeatureImports = import "${inputs.self}/lib/mkFeatureImports.nix";
in
{
  imports = mkFeatureImports ./.;
}
```

---

## scan-files.nix

Single-level directory scanner for auto-importing Nix modules. Returns a list of paths (`.nix` files and directories with `default.nix`, excluding `default.nix` itself). Used by `modules/nixpkgs-overlays.nix` to load custom overlays.

---

## ssh-key.nix

Helper for managing SSH keys with agenix. Given a host and key name, returns an attrset with `age.secrets` (encrypted private key) and `home.file` (public key).

```nix
let
  ssh-key = (import "${inputs.self}/lib/ssh-key.nix" { inherit config inputs; }) settings.host;
in
{
  imports = [ (ssh-key "id_ed25519") (ssh-key "id_rsa") ];
}
```

---

## symlink-dir.nix

Recursively creates out-of-store symlinks for an entire directory tree. Walks a directory at eval time with `builtins.readDir` and emits one `mkOutOfStoreSymlink` entry per file, making the entire tree editable without rebuild.

Typically accessed via `config.lib.dotfiles` wrappers defined in `home-manager/home.nix`:

```nix
{
  xdg.configFile = config.lib.dotfiles.configDir "nvim-lazyvim";
}
```
