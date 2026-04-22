# nix-config

Personal NixOS and nix-darwin flake for one user across macOS, Linux, VMs, and home-manager-only hosts.

## Highlights

- One builder flow for Darwin, NixOS, and standalone home-manager hosts.
- Shared system modules in `modules/` plus reusable home-manager features in `home-manager/features/`.
- Preset-based feature composition through `home-manager/presets.nix`.
- Dotfiles tracked in-repo and wired into home-manager.
- Secrets managed with agenix and a separate secrets repository.

## Quick Start

```bash
git clone git@github.com:erning/nix-config.git
cd nix-config
ln -s "$(pwd)/dotfiles" ~/.dotfiles
```

Apply a configuration:

```bash
# macOS / nix-darwin
darwin-rebuild switch --flake .#dragon

# NixOS
nixos-rebuild switch --flake .#phoenix

# home-manager only
nix run home-manager -- switch --flake .#erning@dragon
```

## Validation

```bash
nix flake check
darwin-rebuild build --flake .#dragon
nixos-rebuild dry-build --flake .#phoenix
home-manager build --flake .#erning@dragon
```

Note: the `orbstack` host conditionally imports `/etc/nixos/configuration.nix` so non-OrbStack evaluations do not place a store-external absolute path in `imports`; real OrbStack NixOS environments are expected to provide that file.

## Project Structure

```text
nix-config/
|- flake.nix
|- lib/
|- modules/
|- home-manager/
|- hosts/
|- dev-shells/
|- dotfiles/
`- overlays/
```

- `flake.nix` wires all hosts through `lib/mkSystem.nix` and `lib/mkHome.nix`.
- `modules/` contains shared system behavior.
- `home-manager/features/` contains auto-imported feature modules.
- `hosts/` contains machine-specific `configuration.nix` and `home.nix` pairs.
- `dotfiles/` contains app configs referenced by feature modules.
- `overlays/` is available for custom nixpkgs overlays when needed.

## Host Overview

| Host | System | Role |
|------|--------|------|
| `dragon` | `aarch64-darwin` | primary macOS workstation |
| `dinosaur` | `x86_64-darwin` | Intel macOS workstation |
| `phoenix` | `x86_64-linux` | NixOS laptop |
| `pomelo` | `x86_64-linux` | Fedora + home-manager only |
| `pterosaur` | `x86_64-darwin` | Intel macOS workstation |
| `mango` | `x86_64-darwin` | lightweight macOS host |
| `orbstack` | `aarch64-linux` | NixOS VM with external `/etc/nixos/configuration.nix` |
| `vmfusion` | `aarch64-linux` | NixOS VM |

For host-specific setup and validation flow, see `hosts/README.md`.

## Feature Presets

Feature presets live in `home-manager/presets.nix` and are typically merged in `hosts/<host>/home.nix`.

**Building blocks** (non-overlapping):

| Preset | Purpose |
|--------|---------|
| `core` | essential shells, prompt, editors, git, ssh |
| `terminal` | terminal-focused workflow (neovim, tmux, nushell, zellij, yazi) |
| `languages` | language runtimes (rust, zig, python, go, nodejs, jdk, kotlin) |
| `devtools` | build tools and dev utilities (nix-support, just, direnv, gradle, typst, docker, claude-code, opencode) |
| `graphical` | GUI terminals, fonts, desktop apps |

**Composites** (self-contained):

| Preset | Composition |
|--------|-------------|
| `development` | `core` + `terminal` + `languages` + `devtools` |
| `workstation` | `development` + `graphical` |

For feature-module conventions, see `home-manager/features/AGENTS.md`.

## Common Workflows

- Add a host: update `hosts/` and `flake.nix`; see [`hosts/README.md`](hosts/README.md).
- Add a reusable user feature: create a module in `home-manager/features/`; see [`home-manager/features/AGENTS.md`](home-manager/features/AGENTS.md).
- Change builder flow or presets: see [`lib/README.md`](lib/README.md).
- Change shared system behavior: see [`modules/README.md`](modules/README.md).
- Add or update app configs: see [`dotfiles/README.md`](dotfiles/README.md).
- Add a custom overlay: see [`overlays/README.md`](overlays/README.md).

## License

Personal configuration; use it as reference if useful.
