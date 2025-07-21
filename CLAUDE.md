# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal NixOS/nix-darwin configuration repository using flakes for managing system and home configurations across multiple machines (both macOS and Linux).

## Architecture

### System Structure
- **Flake-based**: Uses `flake.nix` to define system configurations
- **Multi-platform**: Supports both Darwin (macOS) and NixOS systems
- **Dual-track**: Uses both stable and unstable nixpkgs channels
- **Modular**: Split into system and home-manager configurations

### Key Components
- `flake.nix`: Main flake definition with system configurations
- `lib/mkSystem.nix`: Creates system configurations (Darwin/NixOS)
- `lib/mkHome.nix`: Creates home-manager configurations
- `modules/`: Shared system configuration modules
- `home-manager/`: Home-manager specific configurations
- `hosts/`: Host-specific configurations (one directory per machine)
- `home-manager/features/`: Reusable feature modules

## Common Commands

### System Management
```bash
# Apply Darwin configuration
darwin-rebuild switch --flake .#dragon

# Apply NixOS configuration
nixos-rebuild switch --flake .#phoenix

# Apply home-manager configuration (standalone)
nix run home-manager -- switch --flake .#erning@dragon
```

### Development
```bash
# Enter development shell
nix develop

# Update flake inputs
nix flake update

# Check flake health
nix flake check
```

### VM Management
```bash
# Bootstrap a new VM (requires NIXADDR, NIXPORT)
make vm/bootstrap0

# Configure existing VM
nixos-rebuild switch --flake .#vm-aarch64 --target-host root@$NIXADDR -p $NIXPORT
```

## Host Configurations

### Active Hosts
- **dragon**: aarch64-darwin (MacBook Pro 16-inch 2021)
- **dinosaur**: x86_64-darwin (MacBook Pro 16-inch 2019)
- **phoenix**: x86_64-linux (MacBook Pro 17-inch 2010 - NixOS)
- **pomelo**: x86_64-linux (MacBook Air 13-inch 2019 - Fedora + home-manager)
- **pterosaur**: x86_64-darwin (MacBook Pro 15-inch 2016)
- **mango**: x86_64-darwin (MacBook 12-inch 2015)
- **orb-aarch64**: aarch64-linux (OrbStack VM)
- **vm-aarch64**: aarch64-linux (VMware Fusion VM)

### Deprecated Hosts
- **pineapple**: x86_64-darwin (dual-boot with pomelo)

## Feature System

Features are modular configurations defined in `home-manager/features/` that can be included per-host. Features are automatically imported via `scan-files.nix` which includes all `.nix` files except `default.nix`.

Common features include:
- Development tools (git, nodejs, python, rust, go, etc.)
- Terminal tools (alacritty, kitty, tmux, zellij)
- Shells (bash, zsh, fish, nushell)
- Editors (neovim, vim, zed)

## Secrets Management

Uses `agenix` for encrypted secrets stored in a separate private repository (`nix-secrets`).

## File Structure Key
- `hosts/HOSTNAME/configuration.nix`: System-specific NixOS/Darwin config
- `hosts/HOSTNAME/home.nix`: Host-specific home-manager config
- `home-manager/features/*.nix`: Reusable home-manager modules
- `modules/`: Shared system modules
- `lib/`: Utility functions for configuration generation