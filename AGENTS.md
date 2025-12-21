# Repository Guidelines for AI Agents

This document provides context for AI coding assistants working with this repository.

## Repository Overview

Personal NixOS/nix-darwin configuration repository using flakes for managing system and home configurations across multiple machines (macOS and Linux).

## Project Structure

```
nix-config/
├── flake.nix                 # Main flake - defines all system/home configurations
├── flake.lock                # Locked flake inputs
├── lib/                      # Utility functions and builders
│   ├── mkSystem.nix         # Creates Darwin/NixOS system configurations
│   ├── mkHome.nix           # Creates home-manager configurations
│   ├── features.nix         # Feature presets (base, develop, console, desktop)
│   ├── scan-files.nix       # Auto-import utility for .nix files
│   └── ssh-key.nix          # SSH key helper for agenix
├── modules/                  # Shared system modules (imported by mkSystem)
│   ├── system.nix           # Base config (shells, openssh, timezone)
│   ├── darwin.nix           # macOS: dock, trackpad, keyboard settings
│   ├── nixos.nix            # NixOS: locale, firewall, networkmanager
│   ├── nix-settings.nix     # Nix daemon settings
│   ├── nixpkgs-config.nix   # Allow unfree packages
│   ├── nixpkgs-overlays.nix # Package overlays
│   ├── packages.nix         # System-wide packages
│   └── secrets.nix          # Agenix integration
├── home-manager/            # Home-manager configurations
│   ├── home.nix             # Base home config (xdg, sessionPath)
│   ├── darwin.nix           # macOS-specific home settings
│   ├── nixos.nix            # Linux-specific home settings
│   ├── packages.nix         # User packages
│   ├── secrets.nix          # User-level agenix
│   └── features/            # 35+ modular feature modules
├── hosts/                   # Host-specific configurations
│   └── <hostname>/
│       ├── configuration.nix  # System config (Darwin/NixOS)
│       └── home.nix           # Home-manager config
├── dev-shells/              # Reusable development environments
│   ├── rust/               # Rust dev shell
│   └── mysqlclient/        # MySQL client dev shell
├── dotfiles/                # Shared dotfiles (symlinked to ~/.dotfiles)
│   ├── .config/            # XDG config files
│   ├── .local/             # Local binaries
│   └── .ssh/               # SSH config
├── overlays/                # Custom package overlays
└── Makefile                 # VM bootstrap utilities
```

## Host Configurations

| Host | System | Hardware | OS | Notes |
|------|--------|----------|-----|-------|
| dragon | aarch64-darwin | MacBook Pro 16" 2021 | macOS Sequoia | Primary machine |
| dinosaur | x86_64-darwin | MacBook Pro 16" 2019 | macOS Sequoia | Intel Mac |
| phoenix | x86_64-linux | MacBook Pro 17" 2010 | NixOS | Legacy hardware |
| pomelo | x86_64-linux | MacBook Air 13" 2019 | Fedora | home-manager only |
| pterosaur | x86_64-darwin | MacBook Pro 15" 2016 | macOS Monterey | Older macOS |
| mango | x86_64-darwin | MacBook 12" 2015 | macOS Big Sur | Oldest supported |
| orb-aarch64 | aarch64-linux | OrbStack VM | NixOS | Development VM |
| vm-aarch64 | aarch64-linux | VMware Fusion | NixOS | Development VM |

## Build Commands

```bash
# Darwin (macOS)
darwin-rebuild switch --flake .#dragon
darwin-rebuild switch --flake .#dinosaur
darwin-rebuild switch --flake .#pterosaur
darwin-rebuild switch --flake .#mango

# NixOS
nixos-rebuild switch --flake .#phoenix
nixos-rebuild switch --flake .#orb-aarch64
nixos-rebuild switch --flake .#vm-aarch64

# Home Manager (standalone)
nix run home-manager -- switch --flake .#erning@dragon
nix run home-manager -- switch --flake .#erning@phoenix
nix run home-manager -- switch --flake .#erning@pomelo

# Development
nix develop              # Enter dev shell
nix flake update         # Update inputs
nix flake check          # Validate flake

# Dry run (test without applying)
darwin-rebuild dry-build --flake .#dragon
nixos-rebuild dry-build --flake .#phoenix

# Build specific output
nix build .#darwinConfigurations.dragon.system
nix build .#homeConfigurations."erning@dragon".activationPackage
```

## Key Architecture Concepts

### Flake Inputs
- **nixpkgs-stable** / **nixpkgs-unstable**: Dual-track package sources
- **nix-darwin-stable** / **nix-darwin-unstable**: macOS system management
- **home-manager-stable** / **home-manager-unstable**: User environment management
- **agenix**: Secrets management with age encryption
- **secrets**: Private repository with encrypted secrets

### Configuration Flow
1. `flake.nix` defines configurations using `mkSystem` and `mkHome`
2. `mkSystem` imports `modules/system.nix` + host-specific `configuration.nix`
3. `mkHome` imports `home-manager/home.nix` + host-specific `home.nix`
4. Features are enabled via `features.<name>.enable = true`

### Feature System
Features in `home-manager/features/` are auto-imported via `scan-files.nix`. Each feature is a NixOS module with an `enable` option.

**Feature Presets** (defined in `lib/features.nix`):
- **base**: fish, bash, zsh, starship, eza, fzf, bat, vim, git, ssh
- **develop**: base + tmux, neovim, build-essential, rustup, zig, python, go, nodejs, jdk, kotlin, gradle, just, direnv, typst, docker
- **console**: base + tmux, neovim, nushell, zellij, zoxide, yazi
- **desktop**: base + fonts, zed, ghostty, kitty, alacritty

**Using Presets**:
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

### Secrets Management
- Uses [agenix](https://github.com/ryantm/agenix) with age encryption
- Secrets stored in private `nix-secrets` repository
- System keys: `/etc/age/keys.txt`, `/etc/age/ssh_host_ed25519.txt`
- User keys: `~/.config/age/keys.txt`
- SSH host keys auto-converted to age keys via activation script

## Coding Style

### Nix Formatting
- **Indentation**: 2 spaces
- **Line endings**: LF with final newline
- **Charset**: UTF-8
- **Trailing whitespace**: Trimmed

### Naming Conventions
- **Hosts**: lowercase, single words or hyphenated (dragon, vm-aarch64)
- **Features**: lowercase, hyphenated (build-essential, nix-support)
- **Modules**: lowercase, hyphenated (nixpkgs-config.nix)
- **Variables**: camelCase (isDarwin, rootDir, settings)
- **Let bindings**: camelCase
- **Attribute sets**: lowercase with hyphens for package names

### Common Patterns

**Platform detection**:
```nix
isDarwin = builtins.match ".*-darwin" settings.system != null;
```

**Conditional imports**:
```nix
imports = [
  (if isDarwin then ./darwin.nix else ./nixos.nix)
];
```

**Feature module template**:
```nix
{ config, lib, pkgs, ... }:
{
  options.features.<name>.enable = lib.mkEnableOption "<description>";
  
  config = lib.mkIf config.features.<name>.enable {
    home.packages = with pkgs; [ ... ];
    programs.<name> = { ... };
  };
}
```

## Testing & Validation

```bash
# Syntax and evaluation check
nix flake check

# Build without switching
darwin-rebuild dry-build --flake .#<host>
nixos-rebuild dry-build --flake .#<host>

# Build specific configuration
nix build .#darwinConfigurations.<host>.system
nix build .#nixosConfigurations.<host>.config.system.build.toplevel
```

**Before committing**:
1. Run `nix flake check`
2. Test build on at least one target platform
3. Verify home-manager activation if features changed

## Commit Message Style

- Use present tense imperative ("add", "update", "fix", "remove")
- Be concise but descriptive
- Format: `<action> <scope>: <description>`

**Examples**:
```
add feature: kotlin development support
update flake inputs
fix ssh config for phoenix host
remove deprecated codex config
update cce configs: add minimax-m2 profile
```

## Common Tasks

### Adding a New Feature
1. Create `home-manager/features/<name>.nix`
2. Follow the feature module template above
3. Optionally add to a preset in `lib/features.nix`
4. Enable in host's `home.nix`

### Adding a New Host
1. Create `hosts/<hostname>/configuration.nix` (system config)
2. Create `hosts/<hostname>/home.nix` (home-manager config)
3. Add entries to `flake.nix` using `mkSystem` and `mkHome`

### Updating Packages
```bash
nix flake update                    # Update all inputs
nix flake lock --update-input nixpkgs-unstable  # Update specific input
```

## File Locations Reference

| Purpose | Location |
|---------|----------|
| System packages | `modules/packages.nix` |
| User packages | `home-manager/packages.nix`, `hosts/<host>/home.nix` |
| Shell configuration | `home-manager/features/{fish,bash,zsh}.nix` |
| Editor configuration | `home-manager/features/{vim,neovim}.nix` |
| Terminal emulators | `home-manager/features/{ghostty,kitty,alacritty}.nix` |
| Development tools | `home-manager/features/{rustup,go,python,nodejs}.nix` |
| macOS defaults | `modules/darwin.nix` |
| NixOS services | `modules/nixos.nix`, `hosts/<host>/configuration.nix` |
| Dotfiles | `dotfiles/.config/`, symlinked to `~/.dotfiles` |
