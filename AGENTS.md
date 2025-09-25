# Repository Guidelines

## Project Structure & Module Organization

This Nix configuration repository follows a modular structure with clear separation of concerns:

- `flake.nix` - Main flake entry point defining system and home configurations
- `hosts/` - Host-specific configurations (dragon, dinosaur, phoenix, etc.)
- `home-manager/` - Home Manager modules and feature configurations
- `modules/` - Shared system modules (nixos, darwin, packages, etc.)
- `lib/` - Utility functions for system and home configuration
- `dotfiles/` - Personal dotfiles symlinked to home directory
- `dev-shells/` - Development shell configurations

## Build, Test, and Development Commands

### System Deployment
```bash
# Deploy Darwin system configuration
darwin-rebuild switch --flake .#dragon

# Deploy NixOS system configuration
nixos-rebuild switch --flake .#phoenix

# Deploy Home Manager configuration
nix run home-manager -- switch --flake .#erning@dragon
```

### Development Setup
```bash
# Set up development environment with flakes
use flake  # in .envrc

# Bootstrap Linux VM (via Makefile)
make vm/bootstrap0
```

## Coding Style & Naming Conventions

### Nix Style
- **Indentation**: 2 spaces (configured in .editorconfig)
- **Line endings**: LF with final newline
- **Charset**: UTF-8
- **Trim trailing whitespace**

### Naming Patterns
- **Host names**: Use lowercase with hyphens (dragon, dinosaur, phoenix)
- **Features**: Use lowercase with hyphens in `home-manager/features/`
- **Modules**: Use lowercase with hyphens in `modules/`
- **Variables**: Use camelCase for Nix variables

## Testing Guidelines

### Configuration Testing
```bash
# Test configuration syntax
nix flake check

# Dry run builds
darwin-rebuild dry-build --flake .#dragon
nixos-rebuild dry-build --flake .#phoenix
```

### Validation
- All configurations should build without warnings
- Test on target host before merging
- Verify Home Manager activation works correctly

## Commit & Pull Request Guidelines

### Commit Messages
- Use present tense ("add feature" not "added feature")
- Be concise but descriptive
- Examples from project history:
  - "add dev-shells: rust"
  - "update theme for version 1.2.0"
  - "disable zig on darwin-x86_64"

### Pull Request Requirements
- Link relevant issues if applicable
- Include description of changes
- Test on at least one target system
- Ensure flake checks pass

## Architecture Overview

This repository supports multiple systems:
- **Darwin systems**: macOS with nix-darwin + home-manager
- **NixOS systems**: Pure NixOS with home-manager
- **Linux systems**: Distribution-agnostic with home-manager

Each system is defined in `flake.nix` using `mkSystem` and `mkHome` functions from `lib/`, ensuring consistent configuration patterns across all platforms.
