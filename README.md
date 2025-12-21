# nix-config

Personal NixOS and nix-darwin configuration using flakes for managing system and home configurations across multiple machines (macOS and Linux).

## Features

- **Multi-platform**: Supports both macOS (nix-darwin) and Linux (NixOS)
- **Flake-based**: Modern Nix flakes for reproducible builds
- **Dual-track channels**: Uses both stable (25.05) and unstable nixpkgs
- **Modular features**: 35+ reusable home-manager feature modules
- **Secrets management**: Encrypted secrets via [agenix](https://github.com/ryantm/agenix)

## Project Structure

```
nix-config/
├── flake.nix                 # Main flake definition
├── lib/                      # Utility functions
│   ├── mkSystem.nix         # System configuration builder
│   ├── mkHome.nix           # Home-manager configuration builder
│   ├── features.nix         # Feature presets (base, develop, console, desktop)
│   └── scan-files.nix       # Auto-import utility
├── modules/                  # Shared system modules
│   ├── system.nix           # Base system configuration
│   ├── darwin.nix           # macOS-specific settings
│   ├── nixos.nix            # NixOS-specific settings
│   └── secrets.nix          # Agenix integration
├── home-manager/            # Home-manager configurations
│   ├── home.nix             # Base home configuration
│   └── features/            # Modular feature modules
├── hosts/                   # Host-specific configurations
├── dev-shells/              # Development environments
├── dotfiles/                # Shared dotfiles (symlinked)
└── overlays/                # Custom package overlays
```

## Hosts

| Host | System | Hardware | OS |
|------|--------|----------|-----|
| **dragon** | aarch64-darwin | MacBook Pro 16" 2021 | macOS Sequoia |
| **dinosaur** | x86_64-darwin | MacBook Pro 16" 2019 | macOS Sequoia |
| **phoenix** | x86_64-linux | MacBook Pro 17" 2010 | NixOS |
| **pomelo** | x86_64-linux | MacBook Air 13" 2019 | Fedora + home-manager |
| **pterosaur** | x86_64-darwin | MacBook Pro 15" 2016 | macOS Monterey |
| **mango** | x86_64-darwin | MacBook 12" 2015 | macOS Big Sur |
| **orb-aarch64** | aarch64-linux | OrbStack VM | NixOS |
| **vm-aarch64** | aarch64-linux | VMware Fusion VM | NixOS |

## Quick Start

### Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- For macOS: [nix-darwin](https://github.com/LnL7/nix-darwin)

### Clone and Setup

```bash
git clone git@github.com:erning/nix-config.git
cd nix-config

# Symlink dotfiles
ln -s "$(pwd)/dotfiles" ~/.dotfiles
```

### Apply Configuration

**macOS (nix-darwin):**
```bash
darwin-rebuild switch --flake .#dragon
```

**NixOS:**
```bash
nixos-rebuild switch --flake .#phoenix
```

**Home Manager (standalone):**
```bash
nix run home-manager -- switch --flake .#erning@dragon
```

## Feature System

Features are modular configurations in `home-manager/features/`. They are organized into presets defined in `lib/features.nix`:

| Preset | Description |
|--------|-------------|
| **base** | Essential tools: shells (fish, bash, zsh), starship, eza, fzf, bat, vim, git, ssh |
| **develop** | Development environment: tmux, neovim, rustup, zig, python, go, nodejs, java, docker |
| **console** | Terminal tools: tmux, neovim, nushell, zellij, zoxide, yazi |
| **desktop** | GUI applications: fonts, zed, ghostty, kitty, alacritty |

### Available Features

**Shells & Prompts:** fish, bash, zsh, nushell, starship

**Editors:** vim, neovim, zed

**Terminals:** alacritty, kitty, ghostty

**Development:** rustup, zig, python, go, nodejs, jdk, kotlin, gradle, docker, typst

**Tools:** tmux, zellij, fzf, bat, eza, yazi, zoxide, direnv, just, git, ssh

**Desktop:** fonts (including Source Han for CJK support)

### Using Features

In host-specific `home.nix`:

```nix
{ lib, inputs, ... }:
let
  features = import "${inputs.self}/lib/features.nix" { inherit lib; };
in
{
  features = lib.mkMerge [
    features.console
    features.desktop
    features.develop
  ];
}
```

Or enable individual features:

```nix
{
  features = {
    fish.enable = true;
    neovim.enable = true;
    rustup.enable = true;
  };
}
```

## Development

```bash
# Enter development shell
nix develop

# Update flake inputs
nix flake update

# Check flake health
nix flake check

# Dry run build
darwin-rebuild dry-build --flake .#dragon
nixos-rebuild dry-build --flake .#phoenix
```

## Dev Shells

Reusable development environments in `dev-shells/`:

- **rust** - Rust development environment
- **mysqlclient** - MySQL client development

### Using Flake Dev Shells

Create a `flake.nix` in your project:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = [ pkgs.openssl ];
        };
      }
    );
}
```

Add `use flake` to `.envrc` for automatic activation with direnv.

## VM Bootstrap

For setting up a new NixOS VM:

```bash
export NIXADDR=192.168.x.x
export NIXPORT=22
make vm/bootstrap0
```

## Secrets Management

Secrets are managed with [agenix](https://github.com/ryantm/agenix) and stored in a separate private repository (`nix-secrets`).

The system automatically converts SSH host keys to age keys for decryption:
- System secrets: `/etc/age/keys.txt`
- User secrets: `~/.config/age/keys.txt`

## License

Personal configuration - feel free to use as reference.
