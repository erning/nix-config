# Nix Configuration Project

## Project Overview

This is a comprehensive Nix configuration project that manages system and user configurations across multiple machines using Nix flakes, nix-darwin, and home-manager. The project provides a unified approach to manage macOS and Linux systems with declarative configurations.

The project supports multiple hosts including:
- **dragon**: MacBookPro18,2 (16-inch, 2021) - macOS (Sequoia - 15.5) with aarch64-darwin
- **dinosaur**: MacBookPro16,1 (16-inch, 2019) - macOS (Sequoia - 15.5) with x86_64-darwin
- **phoenix**: MacBookPro6,1 (17-inch, Mid 2010) - NixOS with x86_64-linux
- **pomelo**: MacBookAir8,2 (Retina, 13-inch, 2019) - Fedora with x86_64-linux
- **pterosaur**: MacBookPro13,3 (15-inch, 2016) - macOS (Monterey - 12.7.6) with x86_64-darwin
- **mango**: MacBook8,1 (Retina, 12-inch, Early 2015) - macOS (Big Sur - 11.7.10) with x86_64-darwin
- **orbstack**: OrbStack with aarch64-linux
- **vmfusion**: VM Fusion with aarch64-linux

## Architecture

The project uses a modular architecture with the following key components:

- **flake.nix**: Main entry point that defines inputs from nixpkgs, nix-darwin, home-manager (both stable and unstable versions), agenix for secret management, and external secrets
- **lib/mkSystem.nix** and **lib/mkHome.nix**: Helper functions that abstract the creation of system and home-manager configurations
- **modules/**: Contains reusable system configuration modules
- **home-manager/**: Contains reusable home-manager configuration modules
- **hosts/**: Host-specific configuration overrides
- **dotfiles/**: Contains user dotfiles
- **dev-shells/**: Development shell configurations

## Configuration Components

### System Modules
The system configuration is composed of several modules:
- `nix-settings.nix`: Nix configuration settings
- `nixpkgs-config.nix`: Nixpkgs configuration
- `nixpkgs-overlays.nix`: Package overlays
- `darwin.nix` or `nixos.nix`: Platform-specific settings
- `packages.nix`: System-wide packages
- `secrets.nix`: Secret management with agenix

### Secret Management
The project uses agenix (age-based secret encryption) for managing sensitive data. The secrets module:
- Installs age and ssh-to-age tools
- Sets up identity paths for decrypting secrets
- Includes activation scripts to convert SSH host keys to age format

### Home-Manager Configuration
The user configuration is split into:
- `home.nix`: Main home-manager entry point
- `darwin.nix` or `nixos.nix`: Platform-specific user settings
- `packages.nix`: User-specific packages
- `secrets.nix`: User-level secrets
- `features/`: Additional feature modules

## Building and Running

### Initial Setup
```bash
$ git clone git@github.com:erning/nix-config.git

$ cd nix-config
$ darwin-rebuild switch --flake .#dragon  # For macOS systems

$ ln -s "$(pwd)/dotfiles" ~/.dotfiles
$ nix run home-manager -- switch --flake .#erning@dragon
```

### Commands for Different Hosts
To rebuild specific system configurations:
- For macOS systems: `darwin-rebuild switch --flake .#<hostname>`
- For NixOS systems: `sudo nixos-rebuild switch --flake .#<hostname>`
- For home-manager: `nix run home-manager -- switch --flake .#<user>@<hostname>`

### Development Shell Setup
The project supports development shells with the pattern shown in the README example. Add `use flake` to `.envrc` to automatically enable flake-based development shells.

## Special Features

1. **Dual Channel Support**: Uses both stable (25.05) and unstable channels of nixpkgs, nix-darwin, and home-manager
2. **Cross-Platform**: Supports both macOS and Linux systems from a single configuration
3. **Encrypted Secrets**: Implements agenix for secure secret management
4. **Multiple Architecture Support**: Handles both x86_64 and aarch64 architectures
5. **SSH Configuration**: Includes SSH server setup and user SSH key management

## Key Dependencies

- nixpkgs (stable/unstable channels)
- nix-darwin (for macOS systems)
- home-manager (for user environments)
- agenix (for secret encryption)
- External secrets repository (nix-secrets)

## Development Conventions

The project follows standard NixOS and nix-darwin conventions:
- Declarative system configuration
- Modular design with reusable components
- Version-controlled infrastructure
- Consistent naming patterns for hosts and configurations