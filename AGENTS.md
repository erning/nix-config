# Repository Guidelines for AI Agents

Personal NixOS/nix-darwin configuration repository using flakes for managing system and home configurations across multiple machines (macOS and Linux).

## Structure

```
nix-config/
├── flake.nix       # Main flake - defines all system/home configurations
├── lib/            # Utility functions (mkSystem, mkHome, features, scan-files)
├── modules/        # Shared system modules
├── home-manager/   # Home-manager configs (35+ feature modules)
├── hosts/          # Host-specific configurations
├── dev-shells/     # Reusable development environments
├── dotfiles/       # Shared dotfiles (symlinked to ~/.dotfiles)
└── overlays/       # Custom package overlays
```

## Key Architecture Concepts

### Flake Inputs
- **nixpkgs-stable/unstable**: Dual-track package sources
- **nix-darwin-stable/unstable**: macOS system management
- **home-manager-stable/unstable**: User environment management
- **agenix**: Secrets management with age encryption
- **secrets**: Private repository with encrypted secrets

### Configuration Flow
1. `flake.nix` defines configs using `mkSystem` and `mkHome`
2. `mkSystem` imports `modules/system.nix` + host `configuration.nix`
3. `mkHome` imports `home-manager/home.nix` + host `home.nix`
4. Features enabled via `features.<name>.enable = true`

### Feature System
Features in `home-manager/features/` are auto-imported via `scan-files.nix`. Each is a NixOS module with `enable` option.

**Feature Presets** (defined in `lib/features.nix`):
- **base**: fish, bash, zsh, starship, eza, fzf, bat, vim, git, ssh
- **develop**: base + tmux, neovim, rustup, python, go, nodejs, docker
- **console**: base + tmux, neovim, nushell, zellij, zoxide, yazi
- **desktop**: base + fonts, zed, ghostty, kitty, alacritty

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

Uses [agenix](https://github.com/ryantm/agenix) with age encryption. Secrets in private `nix-secrets` repo.

## Coding Style

### Nix Formatting
- **Indentation**: 2 spaces
- **Line endings**: LF with final newline
- **Charset**: UTF-8
- **Trailing whitespace**: Trimmed

### Naming Conventions
- **Hosts**: lowercase, hyphenated (dragon, vm-aarch64)
- **Features**: lowercase, hyphenated (build-essential, nix-support)
- **Variables**: camelCase (isDarwin, rootDir, settings)
- **Packages**: lowercase with hyphens

### Common Patterns

**Platform detection**:
```nix
isDarwin = builtins.match ".*-darwin" settings.system != null;
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

## Build Commands

```bash
# macOS (nix-darwin)
darwin-rebuild switch --flake .#dragon

# NixOS
nixos-rebuild switch --flake .#phoenix

# Home Manager (standalone)
nix run home-manager -- switch --flake .#erning@dragon

# Development
nix develop              # Enter dev shell
nix flake update         # Update inputs
nix flake check          # Validate flake

# Dry run
darwin-rebuild dry-build --flake .#dragon
nixos-rebuild dry-build --flake .#phoenix
```

## Testing & Validation

```bash
nix flake check
darwin-rebuild dry-build --flake .#<host>
nixos-rebuild dry-build --flake .#<host>
```

**Before committing**: Run `nix flake check`, test build on at least one target platform, verify home-manager activation if features changed.

## Commit Message Style

Present tense imperative ("add", "update", "fix", "remove"). Format: `<action> <scope>: <description>`

Examples: `add feature: kotlin development support`, `update flake inputs`, `fix ssh config for phoenix host`

## Common Tasks

### Adding a New Feature
Create `home-manager/features/<name>.nix` following feature module template, optionally add to preset in `lib/features.nix`, enable in host's `home.nix`.

### Adding a New Host
Create `hosts/<hostname>/configuration.nix` and `hosts/<hostname>/home.nix`, add entries to `flake.nix` using `mkSystem` and `mkHome`.

### Updating Packages
```bash
nix flake update                    # Update all inputs
nix flake lock --update-input nixpkgs-unstable  # Update specific input
```

## Notes

- **No CI/CD**: Lacks automated testing or CI workflows
- **Manual validation**: Always run `nix flake check` and dry-build before switching
- **Custom builders**: Use `mkSystem` and `mkHome` in `flake.nix` for new hosts
- **Feature auto-import**: New features in `home-manager/features/` automatically available
- **Deviation**: `hosts/orbstack/configuration.nix` imports external system config
