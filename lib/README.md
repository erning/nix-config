# Library Utilities

Core utility functions for building NixOS/nix-darwin system and home-manager configurations.

## mkSystem.nix

Creates system configurations for both Darwin (macOS) and NixOS platforms using a unified interface.

### Purpose
Abstracts platform-specific differences, allowing `flake.nix` to define all hosts with a single builder function instead of separate `darwinSystem` and `nixosSystem` calls.

### Parameters
- **host** (string): Hostname (e.g., `"dragon"`, `"phoenix"`)
- **system** (string): Platform triple (e.g., `"aarch64-darwin"`, `"x86_64-linux"`)
- **nixpkgs**: Nixpkgs flake input
- **nix-darwin**: Nix-darwin flake input
- **inputs**: All flake inputs (passed via `...`)

### Return Value
Returns either `nix-darwin.lib.darwinSystem` or `nixpkgs.lib.nixosSystem` depending on platform.

### Platform Detection
```nix
isDarwin = builtins.match ".*-darwin" system != null;
```
Uses regex pattern matching to detect if `system` string contains "-darwin".

### Settings Object
Creates a `settings` attribute set passed to modules via `specialArgs`:
```nix
settings = {
  host = "dragon";
  system = "aarch64-darwin";
};
```
This allows modules to access host and system information.

### Module Import Order
1. `${rootDir}/modules/system.nix` - Base system configuration
2. `${rootDir}/hosts/${host}/configuration.nix` - Host-specific overrides

### Usage Example
```nix
darwinConfigurations.dragon = mkSystem {
  host = "dragon";
  system = "aarch64-darwin";
};

nixosConfigurations.phoenix = mkSystem {
  host = "phoenix";
  system = "x86_64-linux";
};
```

---

## mkHome.nix

Creates home-manager configurations for user environments with a unified interface.

### Purpose
Provides a single builder for all home-manager configurations across different platforms and hosts.

### Parameters
- **user** (string): Username (e.g., `"erning"`)
- **host** (string): Hostname (e.g., `"dragon"`)
- **system** (string): Platform triple (e.g., `"aarch64-darwin"`)
- **nixpkgs**: Nixpkgs flake input
- **home-manager**: Home-manager flake input
- **inputs**: All flake inputs (passed via `...`)

### Return Value
Returns `home-manager.lib.homeManagerConfiguration` with appropriate `pkgs` set.

### Package Resolution
```nix
pkgs = nixpkgs.legacyPackages.${system};
```
Uses `legacyPackages` to ensure compatibility with home-manager's expectations.

### Settings Object
Creates a `settings` attribute set passed to modules via `extraSpecialArgs`:
```nix
settings = {
  user = "erning";
  host = "dragon";
  system = "aarch64-darwin";
};
```
Allows feature modules to access user, host, and system context.

### Module Import Order
1. `${rootDir}/modules/nixpkgs-config.nix` - Nixpkgs configuration (allowUnfree, etc.)
2. `${rootDir}/modules/nixpkgs-overlays.nix` - Custom package overlays
3. `${rootDir}/home-manager/home.nix` - Base home-manager configuration
4. `${rootDir}/hosts/${host}/home.nix` - Host-specific user settings

### Usage Example
```nix
homeConfigurations."erning@dragon" = mkHome {
  user = "erning";
  host = "dragon";
  system = "aarch64-darwin";
};

homeConfigurations."erning@phoenix" = mkHome {
  user = "erning";
  host = "phoenix";
  system = "x86_64-linux";
};
```

---

## features.nix

Defines feature presets that enable groups of related tools and configurations.

### Purpose
Simplify host configuration by providing pre-defined feature sets instead of individually enabling dozens of features.

### Presets

#### base
Essential tools for any system:
- **Shells**: fish, bash, zsh
- **Prompt**: starship
- **CLI tools**: eza, fzf, bat
- **Editors**: vim
- **Dev tools**: git, ssh

#### develop
Development environment with build tools, runtimes, and IDE:
- **Extends**: base
- **Editors**: neovim, tmux
- **Build tools**: build-essential, nix-support, just, gradle
- **Languages**: rustup, zig, python, go, nodejs, jdk, kotlin
- **Dev tools**: direnv
- **Other**: typst, docker

#### console
Terminal-focused environment with modern CLI tools:
- **Extends**: base
- **Editors**: neovim, tmux
- **Shells**: nushell (modern replacement for bash/zsh)
- **Tools**: zellij (terminal multiplexer), zoxide (cd replacement), yazi (file manager)

#### desktop
GUI applications and desktop environment tools:
- **Extends**: base
- **Fonts**: fonts, source-han (CJK fonts)
- **Editors**: zed
- **Terminals**: ghostty, kitty, alacritty

### Combination Strategy
Uses `//` (right-biased attribute update) to merge presets:
```nix
develop = { ... } // base;
```
This means `develop` preset overrides `base` defaults while inheriting all base features.

### Using Presets
```nix
{ lib, inputs, ... }:
let
  features = import "${inputs.self}/lib/features.nix" { inherit lib; };
in
{
  features = lib.mkMerge [
    features.develop   # Enables base + develop features
    features.desktop  # Also enables desktop features
  ];
}
```

### Custom Presets
Create your own by defining attribute sets with `lib.mkDefault`:
```nix
my-preset = {
  neovim.enable = lib.mkDefault true;
  python.enable = lib.mkDefault true;
} // base;
```

---

## scan-files.nix

Auto-import utility for discovering and importing Nix modules from a directory.

### Purpose
Enables automatic module discovery without manually maintaining import lists. Used by `home-manager/features/default.nix` to load all 36+ feature modules.

### Parameters
- **path** (string): Directory path to scan (e.g., `./home-manager/features`)

### Return Value
Returns a list of file paths:
```nix
[ ./fish.nix ./bash.nix ./zsh.nix ... ]
```

### Filtering Logic

1. **Excludes `default.nix`**:
   ```nix
   filter (n: n != "default.nix") (...)
   ```

2. **Includes .nix files**:
   ```nix
   filter (n: match ".*\\.nix" n != null) (...)
   ```

3. **Includes directories with default.nix**:
   ```nix
   filter (n: pathExists (path + ("/" + n + "/default.nix"))) (...)
   ```
   This allows subdirectories with their own `default.nix` to be included.

### Why Dynamic Imports?
- **Scalability**: Adding a new feature module automatically makes it available
- **Maintainability**: No need to update import lists when adding/removing modules
- **Flexibility**: Can easily support new feature types without code changes

### Trade-offs
- **Static analysis**: Dynamic imports reduce ability of some tools (e.g., LSP) to analyze dependencies
- **Debugging**: Harder to trace where a module comes from if it fails to load

### Usage Example
```nix
{ inputs, ... }:

let
  scanFiles = import "${inputs.self}/lib/scan-files.nix";
in
{
  imports = (scanFiles ./.);  # Auto-import all .nix files in current directory
}
```

---

## ssh-key.nix

Helper function for managing SSH keys with age encryption.

### Purpose
Centralizes SSH key management for agenix, reducing duplication across host configurations.

### Parameters
- **host** (string): Hostname (from `settings.host`)
- **name** (string): SSH key name (e.g., `"id_ed25519"`, `"id_rsa"`)

### Return Value
Returns an attribute set with:
- **age.secrets**: Encrypted private key configuration
- **home.file**: Public key source (not encrypted)

### Generated Configuration
```nix
{
  age.secrets."ssh/${host}/${name}" = {
    file = "${inputs.secrets}/ssh/${host}/${name}.age";
    path = "${config.home.homeDirectory}/.ssh/${name}";
    mode = "600";  # Restrictive permissions for private key
  };
  home.file.".ssh/${name}.pub".source = "${inputs.secrets}/ssh/${host}/${name}.pub";
}
```

### Usage Pattern
```nix
{ config, inputs, settings, ... }:

let
  ssh-key = (import "${inputs.self}/lib/ssh-key.nix" { inherit config inputs; }) settings.host;
in
{
  imports = [
    (ssh-key "id_ed25519")  # Import encrypted SSH key
    (ssh-key "id_rsa")
  ];

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/keys.txt"
  ];
}
```

### File Structure
Expected directory layout in secrets repository:
```
nix-secrets/
└── ssh/
    └── <host>/
        ├── id_ed25519.age      # Encrypted private key
        ├── id_ed25519.pub      # Public key (not encrypted)
        ├── id_rsa.age
        └── id_rsa.pub
```

### Integration with Agenix
- Private keys are encrypted and managed by `age.secrets`
- Decrypted keys are placed in `~/.ssh/` with mode 600
- Public keys are symlinked directly (no encryption needed)
- Requires `age.identityPaths` to be configured with your decryption key
