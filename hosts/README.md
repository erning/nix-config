# Host Configurations

Host-specific system and home-manager configurations.

## Purpose

Each host has its own configuration directory containing:
- **configuration.nix**: System-level configuration (NixOS or nix-darwin)
- **home.nix**: User-level configuration (home-manager)

## Host Overview

| Host | System | Hardware | OS |
|-------|--------|----------|-----|
| **dragon** | aarch64-darwin | MacBook Pro 16" 2021 | macOS (nix-darwin) |
| **dinosaur** | x86_64-darwin | MacBook Pro 16" 2019 | macOS (nix-darwin) |
| **phoenix** | x86_64-linux | MacBook Pro 17" 2010 | NixOS |
| **pomelo** | x86_64-linux | MacBook Air 13" 2019 | Fedora + home-manager |
| **pterosaur** | x86_64-darwin | MacBook Pro 15" 2016 | macOS (nix-darwin) |
| **mango** | x86_64-darwin | MacBook 12" 2015 | macOS (nix-darwin) |
| **orbstack** | aarch64-linux | OrbStack VM | NixOS |
| **vmfusion** | aarch64-linux | VMware Fusion VM | NixOS |

## Configuration Files

### configuration.nix

System-level configuration for NixOS or nix-darwin hosts.

#### Common Content

```nix
{
  system.primaryUser = "erning";  # Set primary user

  # Additional system settings can go here
  # These are merged with modules/system.nix
}
```

#### Special Cases

**pomelo**: Does not have `configuration.nix` - uses home-manager only on Fedora

**orbstack**: Imports external system config:
```nix
# hosts/orbstack/configuration.nix
{
  imports = [
    /etc/nixos/configuration.nix  # Import host system config
  ];
}
```
This is a deviation from the standard pattern - used when transitioning existing NixOS installations.

### home.nix

User-level configuration managed by home-manager.

#### Common Pattern

```nix
{ lib, inputs, ... }:

let
  features = import "${inputs.self}/lib/features.nix" { inherit lib; };

  # SSH key helper (optional)
  ssh-key = (import "${inputs.self}/lib/ssh-key.nix" { inherit config inputs; }) settings.host;

in
{
  # Import SSH keys from secrets
  imports = [
    (ssh-key "id_ed25519")
  ];

  # Set age identity paths for secret decryption
  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/keys.txt"
  ];

  # Enable features using presets or individually
  features = lib.mkMerge [
    features.develop
    features.desktop
  ];
}
```

#### Adding Host-Specific Settings

Hosts can override or add settings:

```nix
{
  # Enable a feature not in preset
  features.custom-tool.enable = true;

  # Add host-specific packages
  home.packages = with pkgs; [
    host-specific-tool
  ];

  # Override shell aliases for this host
  programs.fish.shellAliases.la = "ls -lah";
}
```

## Adding a New Host

### 1. Create Host Directory

```bash
mkdir -p hosts/<hostname>
```

### 2. Create System Configuration

Create `hosts/<hostname>/configuration.nix`:

```nix
{
  system.primaryUser = "erning";
}
```

### 3. Create Home Configuration

Create `hosts/<hostname>/home.nix`:

```nix
{ lib, inputs, ... }:

let
  features = import "${inputs.self}/lib/features.nix" { inherit lib; };

in
{
  features = lib.mkMerge [
    features.base
  ];
}
```

### 4. Add to Flake

Add entries to `flake.nix`:

```nix
{
  outputs = { self, nixpkgs, nix-darwin, home-manager, ... } @ inputs: {
    darwinConfigurations.<hostname> = mkSystem {
      host = "<hostname>";
      system = "aarch64-darwin";  # or x86_64-darwin
    };

    homeConfigurations."erning@<hostname>" = mkHome {
      user = "erning";
      host = "<hostname>";
      system = "aarch64-darwin";
    };
  };
}
```

### 5. Test and Apply

```bash
# Dry run to check for errors
darwin-rebuild dry-build --flake .#<hostname>
# or
nixos-rebuild dry-build --flake .#<hostname>

# Apply configuration
darwin-rebuild switch --flake .#<hostname>
# or
nixos-rebuild switch --flake .#<hostname>
```

## Host Configuration Patterns

### Desktop Hosts (dragon, dinosaur, pterosaur, mango)
- Use `features.develop` + `features.desktop`
- Include GUI applications (zed, ghostty, kitty, alacritty)
- Full desktop environment setup

### Server/VM Hosts (phoenix, orbstack, vmfusion)
- May use `features.console` for terminal-focused environment
- Lighter configuration without GUI apps
- May include SSH-accessible settings

### Home-Manager Only (pomelo)
- Fedora distribution with home-manager managing user environment only
- System packages managed by Fedora package manager
- User environment managed by home-manager

## Host-Specific Considerations

### macOS Hosts
- Trackpad gestures configured in `modules/darwin.nix`
- Dock auto-hide enabled
- Caps Lock remapped to Control
- Homebrew paths in `home-manager/darwin.nix`

### NixOS Hosts
- Firewall can be enabled in `modules/nixos.nix`
- NetworkManager for network configuration
- SSH security settings (PasswordAuthentication, PermitRootLogin)

### VM Hosts
- orbstack and vmfusion are identical configurations
- Can be reused for different virtualization platforms

## Testing Host Changes

Always test changes before applying:

```bash
# For macOS
darwin-rebuild dry-build --flake .#<hostname>

# For NixOS
nixos-rebuild dry-build --flake .#<hostname>

# For home-manager only
home-manager switch --flake .#erning@<hostname> --dry-run
```

## Troubleshooting

### Host Not Found in Flake

**Error**: `error: flake 'git+file://...#<hostname>' does not provide attribute`

**Solution**: Ensure host is added to `flake.nix` outputs.

### Configuration Not Applied

**Error**: Changes to `home.nix` not taking effect

**Solution**:
1. Verify syntax: `nix flake check`
2. Rebuild: `darwin-rebuild switch --flake .#<hostname>`
3. Check home-manager activation: `home-manager switch --flake .#erning@<hostname>`

### Platform Mismatch

**Error**: System platform doesn't match configuration

**Solution**: Ensure `system` parameter in `flake.nix` matches actual platform:
- macOS ARM: `aarch64-darwin`
- macOS Intel: `x86_64-darwin`
- Linux ARM: `aarch64-linux`
- Linux Intel: `x86_64-linux`

## Related Documentation

- [lib/mkSystem.md](../lib/README.md#mksystemnix) - System builder
- [lib/mkHome.md](../lib/README.md#mkhomenix) - Home builder
- [modules/README.md](../modules/README.md) - System modules
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
