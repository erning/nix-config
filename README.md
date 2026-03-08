# nix-config

Personal NixOS and nix-darwin flake for one user across macOS, Linux, VMs, and home-manager-only hosts.

## Highlights

- One builder flow for Darwin, NixOS, and standalone home-manager hosts.
- Shared system modules in `modules/` plus reusable home-manager features in `home-manager/features/`.
- Preset-based feature composition through `lib/features.nix`.
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
darwin-rebuild dry-build --flake .#dragon
nixos-rebuild dry-build --flake .#phoenix
home-manager switch --flake .#erning@dragon --dry-run
```

Note: `nix flake check` is not pure-eval-safe on machines that lack `/etc/nixos/configuration.nix` for the `orbstack` host.

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

Feature presets live in `lib/features.nix` and are typically merged in `hosts/<host>/home.nix`.

| Preset | Purpose |
|--------|---------|
| `base` | essential shells, prompt, editors, git, ssh |
| `develop` | language runtimes, build tools, dev utilities |
| `console` | terminal-focused workflow |
| `desktop` | GUI terminals, fonts, desktop apps |

Typical usage:

```nix
{ lib, inputs, ... }:

let
  features = import "${inputs.self}/lib/features.nix" { inherit lib; };
in
{
  features = lib.mkMerge [
    features.develop
    features.desktop
  ];
}
```

For feature-module conventions, see `home-manager/features/AGENTS.md`.

## Common Workflows

- Add a host: update `hosts/` and `flake.nix`; see `hosts/README.md`.
- Add a reusable user feature: create a new module in `home-manager/features/`; see `home-manager/features/AGENTS.md`.
- Change builder flow or presets: use `lib/README.md`.
- Change shared system behavior: use `modules/README.md`.
- Add or update app configs: use `dotfiles/README.md`.
- Add a custom overlay: use `overlays/README.md`.

## Documentation Map

- `AGENTS.md` - concise repo-wide guidance for agents
- `hosts/README.md` - host inventory and human setup notes
- `hosts/AGENTS.md` - host subtree editing rules
- `lib/README.md` - builder and helper reference
- `modules/README.md` - shared system module reference
- `dotfiles/README.md` - dotfile layout and wiring notes
- `overlays/README.md` - overlay usage in this repo
- `docs/homebrew-migration.md` - current migration decision summary
- `docs/features-analysis.md` - supporting feature classification snapshot

## Notes

- `pomelo` is home-manager-only.
- `orbstack` is intentionally special and depends on an external `/etc/nixos/configuration.nix`.
- `lib/README.md` and `modules/README.md` are the detailed references; this file is only the entry point.

## License

Personal configuration; use it as reference if useful.
