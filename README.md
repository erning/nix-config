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
├── flake.nix                # Main flake definition
├── lib/                     # Utility functions
│   ├── mkSystem.nix         # System configuration builder
│   ├── mkHome.nix           # Home-manager configuration builder
│   ├── features.nix         # Feature presets (base, develop, console, desktop)
│   └── scan-files.nix       # Auto-import utility
├── modules/                 # Shared system modules
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

## Core Library Tools

The `lib/` directory contains utility functions that abstract complexity from `flake.nix`. For detailed documentation, see [lib/README.md](lib/README.md).

### mkSystem

Creates system configurations for both Darwin and NixOS platforms using a unified interface.

**Purpose**: Abstracts platform-specific differences, allowing `flake.nix` to define all hosts with a single builder.

**Key Features**:
- Platform detection via regex (`.*-darwin`)
- Automatic import of `darwin.nix` or `nixos.nix` based on platform
- Passes `settings` object with `host` and `system` to modules

### mkHome

Creates home-manager configurations for user environments with a unified interface.

**Purpose**: Provides a single builder for all home-manager configurations across platforms.

**Key Features**:
- Resolves `pkgs` using `legacyPackages` for compatibility
- Passes `settings` object with `user`, `host`, and `system` to feature modules
- Imports base home-manager configuration before host-specific overrides

### features.nix

Defines feature presets that enable groups of related tools and configurations.

**Purpose**: Simplify host configuration by providing pre-defined feature sets.

**Presets**:
- `base`: Essential CLI tools and editors
- `develop`: Development environment with runtimes and tools
- `console`: Terminal-focused with modern replacements (nushell, zellij)
- `desktop`: GUI applications and desktop environment tools

### scan-files.nix

Auto-import utility for discovering and importing Nix modules from a directory.

**Purpose**: Enables automatic module discovery without manually maintaining import lists.

**Key Features**:
- Filters out `default.nix`
- Includes `.nix` files
- Includes directories with `default.nix`
- Used by `home-manager/features/default.nix` for auto-loading 36+ features

## Modules Documentation

The `modules/` directory contains shared system-level configurations imported by all hosts. For detailed documentation, see [modules/README.md](modules/README.md).

### Module Loading Order

1. **nix-settings.nix** - Nix daemon configuration (flakes, caches)
2. **nixpkgs-config.nix** - Nixpkgs options (allowUnfree)
3. **nixpkgs-overlays.nix** - Custom package overlays and unstable/stable access
4. **darwin.nix** or **nixos.nix** - Platform-specific (conditional)
5. **packages.nix** - System-wide packages
6. **secrets.nix** - Agenix integration

### Key Modules

#### nix-settings.nix
Enables experimental features (flakes) and configures binary caches (Chinese mirrors).

#### nixpkgs-config.nix
Allows installation of unfree packages by setting `allowUnfree = true`.

#### nixpkgs-overlays.nix
Provides access to `pkgs.unstable` and `pkgs.stable` channels, plus auto-loads custom overlays from `overlays/` directory.

#### darwin.nix
macOS-specific settings: dock, trackpad, keyboard, system defaults.

#### nixos.nix
NixOS-specific settings: locale, SSH security, networking, firewall.

#### secrets.nix
Agenix integration with automatic SSH host key conversion to age format.

## Dotfiles Management

The `dotfiles/` directory contains shared configuration files managed via home-manager's `xdg.configFile` and `home.file` options.

### Symlink Mechanism

Dotfiles are symlinked to `~/.dotfiles` for easy access outside of Nix:

```bash
ln -s "$(pwd)/dotfiles" ~/.dotfiles
```

### File Organization

```
dotfiles/
├── .config/           # XDG config directory
│   ├── opencode/     # Application configs
│   ├── git/         # Git configuration
│   ├── nvim-lazyvim/
│   └── ...
├── .local/            # Local binaries and data
│   └── bin/         # Custom scripts
└── .npmrc             # NPM configuration
```

### How to Add New Dotfiles

1. Place the file in `dotfiles/` following XDG structure
2. Add to host configuration using `home.file` or `xdg.configFile`:

```nix
home.file.".config/myapp/config.json".source = "${inputs.self}/dotfiles/.config/myapp/config.json";
```

3. The file will be symlinked to `~/.config/myapp/config.json` on activation

### Managed Dotfiles

- **neovim**: LazyVim configuration
- **tmux**: Tmux configuration with Catppuccin theme
- **git**: Git config, ignores, and attributes
- **opencode**: Custom application configurations
- **npm**: NPM configuration

## Host Setup Guides

### New macOS Host

1. Install Nix and nix-darwin following [official instructions](https://github.com/LnL7/nix-darwin)
2. Clone this repository
3. Symlink dotfiles: `ln -s "$(pwd)/dotfiles" ~/.dotfiles`
4. Create `hosts/<hostname>/configuration.nix`:

```nix
{ system.primaryUser = "erning"; }
```

5. Create `hosts/<hostname>/home.nix`:

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

6. Add entries to `flake.nix`:

```nix
darwinConfigurations.<hostname> = mkSystem {
  host = "<hostname>";
  system = "aarch64-darwin";  # or x86_64-darwin
};

homeConfigurations."erning@<hostname>" = mkHome {
  user = "erning";
  host = "<hostname>";
  system = "aarch64-darwin";
};
```

7. Apply: `darwin-rebuild switch --flake .#<hostname>`

### New NixOS Host

Follow similar steps as macOS, but use `nixos-rebuild` instead.

For VMs, use the Makefile bootstrap:

```bash
export NIXADDR=192.168.x.x
export NIXPORT=22
make vm/bootstrap0
```

This will:
- Partition and format the disk
- Install base NixOS
- Configure SSH access
- Install Nix with flakes enabled

**Important**: After bootstrapping, disable password authentication and root login for security:

```nix
# In host configuration.nix or modules/nixos.nix
services.openssh.settings.PasswordAuthentication = false;
services.openssh.settings.PermitRootLogin = "no";
```

### Existing Host Migration

To migrate an existing host to this configuration:

1. Backup current configuration
2. Install Nix if not already installed
3. Follow setup steps above
4. Gradually move existing dotfiles into `dotfiles/` directory
5. Test with `dry-build` before applying: `darwin-rebuild dry-build --flake .#<hostname>`

## Troubleshooting

### Common Issues

#### Flake Check Fails

**Error**: `error: undefined variable 'inputs'`

**Solution**: Ensure `inputs` is passed in the flake outputs:

```nix
{
  outputs = { self, nixpkgs, ... } @ inputs: {
    # Use inputs here
  };
}
```

#### Module Not Found

**Error**: `error: file 'features/my-feature.nix' was not found`

**Solution**:
- Check the file exists in `home-manager/features/`
- Ensure file extension is `.nix`
- Run `nix flake check` to verify

#### Secrets Not Decrypting

**Error**: `age: error: no identity found`

**Solution**:
- Verify `age.identityPaths` points to your decryption key
- Check file exists: `cat ~/.config/age/keys.txt`
- Ensure permissions are correct: `chmod 600 ~/.config/age/keys.txt`

#### Build Fails After Update

**Error**: Package conflict or build failure after `nix flake update`

**Solutions**:
1. Check flake.lock: `git diff flake.lock`
2. Revert to working commit: `git checkout HEAD -- flake.lock`
3. Update specific input only: `nix flake lock --update-input nixpkgs-unstable`
4. Dry-run build: `nix build .#darwinConfigurations.dragon.system --dry-run`

#### Hostname Issues

**Error**: Configuration applies but hostname doesn't match

**Solution**: Ensure `networking.hostName` (NixOS) or `networking.computerName` (Darwin) is set correctly in modules.

### Debugging Commands

```bash
# Check flake syntax
nix flake check

# Check configuration without applying
darwin-rebuild dry-build --flake .#<host>

# Show build derivation
nix build .#darwinConfigurations.<host>.system --show-trace

# Show home-manager activation (dry-run)
home-manager switch --flake .#<user>@<host> --dry-run
```

### Getting Help

- Check [lib/README.md](lib/README.md) for utility function details
- Check [modules/README.md](modules/README.md) for system module documentation
- Review [NixOS Wiki](https://nixos.wiki/)
- Review [nix-darwin Wiki](https://github.com/LnL7/nix-darwin/wiki)
- Check [Home Manager Manual](https://nix-community.github.io/home-manager/)

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

## Contributing

### Adding a New Feature

1. Create `home-manager/features/<name>.nix` following the template:

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

2. Test locally: Enable in your host's `home.nix` and run `nix flake check`
3. Optionally add to a preset in `lib/features.nix`
4. Commit with message: `add feature: <description>`

### Adding a New Host

1. Create `hosts/<hostname>/configuration.nix` and `hosts/<hostname>/home.nix`
2. Add entries to `flake.nix` using `mkSystem` and `mkHome`
3. Test with `dry-build` before applying
4. Commit with message: `add host: <hostname>`

### Code Style

- **Indentation**: 2 spaces
- **Line endings**: LF with final newline
- **Charset**: UTF-8
- **Trailing whitespace**: Trimmed
- **Naming**:
  - Hosts: lowercase, hyphenated (dragon, vm-aarch64)
  - Features: lowercase, hyphenated (build-essential, nix-support)
  - Variables: camelCase (isDarwin, rootDir, settings)

### Commit Message Style

Use present tense imperative ("add", "update", "fix", "remove"). Format: `<action> <scope>: <description>`

Examples:
```
add feature: kotlin development support
update flake inputs
fix ssh config for phoenix host
remove deprecated codex config
```

### Testing Before Committing

1. Run `nix flake check`
2. Test build on at least one target platform: `darwin-rebuild dry-build --flake .#<host>`
3. Verify home-manager activation if features changed: `home-manager switch --dry-run --flake .#<user>@<host>`

## License

Personal configuration - feel free to use as reference.
