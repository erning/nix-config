# Repository Guidelines

## Repository Overview

This is a personal NixOS/nix-darwin configuration repository using flakes for managing system and home configurations across multiple machines (both macOS and Linux).

### Project Structure

```
nix-config/
├── flake.nix                    # Main flake definition with system configurations
├── lib/                         # Utility functions and builders
│   ├── mkSystem.nix            # Creates system configurations (Darwin/NixOS)
│   ├── mkHome.nix              # Creates home-manager configurations
│   └── scan-files.nix          # Auto-import utility for features/modules
├── modules/                     # Shared system configuration modules
│   ├── system.nix              # Base system configuration
│   ├── darwin.nix              # macOS-specific settings
│   ├── nixos.nix               # NixOS-specific settings
│   ├── packages.nix            # Package management
│   └── secrets.nix             # Agenix integration for secrets
├── home-manager/               # Home-manager configurations
│   ├── home.nix                # Base home configuration
│   └── features/               # 38+ modular feature modules
├── hosts/                      # Host-specific configurations (8 hosts)
├── dev-shells/                 # Development environments
├── dotfiles/                   # Shared dotfiles (symlinked)
├── overlays/                   # Custom package overlays
└── Makefile                    # VM bootstrap utilities
```

## Build, Test, and Development Commands

### System Deployment
```bash
# Apply Darwin configuration
darwin-rebuild switch --flake .#dragon
darwin-rebuild switch --flake .#dinosaur
darwin-rebuild switch --flake .#pterosaur
darwin-rebuild switch --flake .#mango

# Apply NixOS configuration
nixos-rebuild switch --flake .#phoenix

# Apply home-manager configuration (standalone)
nix run home-manager -- switch --flake .#erning@dragon
nix run home-manager -- switch --flake .#erning@phoenix
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

## Key Architecture

### System Structure
- **Flake-based**: Uses `flake.nix` to define system configurations
- **Multi-platform**: Supports both Darwin (macOS) and NixOS systems
- **Dual-track**: Uses both stable and unstable nixpkgs channels
- **Modular**: Split into system and home-manager configurations

### Feature System
Features are modular configurations defined in `home-manager/features/` that can be included per-host. Features are automatically imported via `scan-files.nix` which includes all `.nix` files except `default.nix`.

Common feature categories:
- **Base**: Essential tools (shells, vim, git, ssh, etc.)
- **Console**: Terminal tools (alacritty, kitty, tmux, zellij, neovim)
- **Desktop**: GUI applications and fonts
- **Develop**: Development environments (rust, go, python, nodejs, docker, etc.)

### Secrets Management
Uses `agenix` for encrypted secrets stored in a separate private repository (`nix-secrets`).

## Coding Style & Naming Conventions

### Nix Style
- **Indentation**: 2 spaces (configured in .editorconfig)
- **Line endings**: LF with final newline
- **Charset**: UTF-8
- **Trim trailing whitespace**

### Naming Patterns
- **Host names**: Lowercase with hyphens (dragon, dinosaur, phoenix)
- **Features**: Lowercase with hyphens in `home-manager/features/`
- **Modules**: Lowercase with hyphens in `modules/`
- **Variables**: camelCase for Nix variables

## Testing Guidelines

### Configuration Testing
```bash
# Test configuration syntax
nix flake check

# Dry run builds
darwin-rebuild dry-build --flake .#dragon
nixos-rebuild dry-build --flake .#phoenix

# Build specific system
nix build .#darwinConfigurations.dragon.system
```

### Validation Requirements
- All configurations should build without warnings
- Test on target host before merging
- Verify Home Manager activation works correctly
- Ensure flake checks pass before committing

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
- Review configuration impact on all hosts

## Common File Locations

### Host-Specific Files
- `hosts/HOSTNAME/configuration.nix`: System-specific NixOS/Darwin config
- `hosts/HOSTNAME/home.nix`: Host-specific home-manager config

### Modular Features
- `home-manager/features/*.nix`: Reusable home-manager modules
- Features are auto-imported - just create a new `.nix` file to add functionality

### Shared Modules
- `modules/system.nix`: Base system configuration applied to all hosts
- `modules/darwin.nix`: macOS-specific settings
- `modules/nixos.nix`: NixOS-specific settings
- `modules/packages.nix`: Package management and overlays
