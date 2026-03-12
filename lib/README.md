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

### Pinned Builder Variant
Legacy macOS hosts that cannot run nixpkgs-unstable use a pinned variant:
```nix
mkSystem-2505 = import ./lib/mkSystem.nix {
  nixpkgs = inputs.nixpkgs-2505;
  nix-darwin = inputs.nix-darwin-2505;
  inherit inputs;
};

darwinConfigurations."pterosaur" = mkSystem-2505 {
  host = "pterosaur";
  system = "x86_64-darwin";
};
```
The same `mkSystem.nix` is reused — only the nixpkgs and nix-darwin inputs differ.

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

### Pinned Builder Variant
Same pattern as mkSystem — legacy macOS hosts use a pinned variant:
```nix
mkHome-2505 = import ./lib/mkHome.nix {
  nixpkgs = inputs.nixpkgs-2505;
  home-manager = inputs.home-manager-2505;
  inherit inputs;
};

homeConfigurations."erning@pterosaur" = mkHome-2505 {
  user = "erning";
  host = "pterosaur";
  system = "x86_64-darwin";
};
```

### Compatibility Guards in Feature Modules
Because pinned home-manager versions may lack newer options, feature modules should guard version-specific options:
```nix
# Check if an option exists before setting it
programs.go.env = lib.mkIf (options.programs.go ? env) {
  GOPATH = ".go";
};

# Or use optionalAttrs for attribute-set merging
programs.ssh = { ... } // lib.optionalAttrs (options.programs.ssh ? enableDefaultConfig) {
  enableDefaultConfig = false;
};
```
This pattern uses `options ? attr` to test whether the option is defined in the current home-manager version.

---

## presets.nix

> **Note:** This file lives at `home-manager/presets.nix`, not under `lib/`. It is documented here alongside the other builder utilities for convenience.

Defines feature presets that enable groups of related tools and configurations.

### Purpose
Simplify host configuration by providing pre-defined feature sets instead of individually enabling dozens of features.

### Building Blocks (non-overlapping)

#### core
Essential tools for any system:
- **Shells**: fish, bash, zsh
- **Prompt**: starship
- **CLI tools**: eza, fzf, bat
- **Editors**: vim
- **Dev tools**: git, ssh

#### terminal
Terminal-focused environment with modern CLI tools:
- **Editors**: neovim, tmux
- **Shells**: nushell
- **Tools**: zellij (terminal multiplexer), zoxide (cd replacement), yazi (file manager)

#### languages
Language runtimes:
- rustup, zig, python, go, nodejs, jdk, kotlin

#### devtools
Build tools and dev utilities:
- nix-support, just, direnv, gradle, typst, docker, claude-code, opencode

#### graphical
GUI applications and desktop environment tools:
- **Fonts**: fonts, source-han (CJK fonts)
- **Editors**: zed
- **Terminals**: ghostty, kitty, alacritty

### Composites (self-contained)

| Composite | Composition |
|-----------|-------------|
| `development` | `core` + `terminal` + `languages` + `devtools` |
| `workstation` | `development` + `graphical` |

Composites are built with `//` (attribute merge) of their constituent building blocks, so they are self-contained and do not need to be combined with `core` separately.

### Using Presets
```nix
{ lib, inputs, ... }:
let
  presets = import "${inputs.self}/home-manager/presets.nix" { inherit lib; };
in
{
  features = lib.mkMerge [
    presets.workstation   # Enables all building blocks including graphical
  ];
}
```

### Custom Presets
Create your own by defining attribute sets with `lib.mkDefault`:
```nix
my-preset = {
  neovim.enable = lib.mkDefault true;
  python.enable = lib.mkDefault true;
} // core;
```

---

## mkFeatureImports.nix

Auto-wrap utility that recursively scans a directory for feature modules, derives each feature's name from its filename, and wraps it with the standard `options.features.<name>.enable` + `lib.mkIf` boilerplate.

### Purpose
Eliminates repeated boilerplate in feature modules. Each feature file becomes a **pure config function** — no mention of `options`, `mkEnableOption`, or `mkIf` needed.

### Parameters
- **dir** (path): Directory to scan recursively (e.g., `./home-manager/features`)

### Return Value
A list of NixOS-style modules, each defining `options.features.<name>.enable` and `config = lib.mkIf ...`.

### Name Derivation
- `direnv.nix` → feature name `"direnv"`
- `fonts/source-han.nix` → feature name `"fonts.source-han"`
- `default.nix` files are skipped (they serve as importers, not features)

### Feature Module Format
Feature files return a plain config attrset. The wrapper handles everything else:

```nix
# direnv.nix — simplest form
{ pkgs, ... }:
{
  home.packages = with pkgs; [ direnv ];
}

# fonts/source-han.nix — custom description via _description
{ pkgs, ... }:
{
  _description = "fonts - Source Han";
  home.packages = with pkgs.unstable; [ source-han-sans source-han-serif source-han-mono ];
}

# go.nix — version guard still works (options passed through)
{ pkgs, lib, options, ... }:
({
  home.packages = with pkgs; [ go ];
  programs.go.enable = true;
} // lib.optionalAttrs (options.programs.go ? env) {
  programs.go.env = { GOPATH = ".go"; };
})
```

### The `_description` Attribute
If the returned attrset contains `_description`, it overrides the default `mkEnableOption` description (which defaults to the filename-derived name). The `_description` key is stripped from the config before merging.

### How It Works
1. Recursively walks the directory with `builtins.readDir`
2. For each `.nix` file (except `default.nix`), derives a feature name from the path
3. Wraps the imported module in a NixOS module that:
   - Declares `options.features.<name>.enable = lib.mkEnableOption description;`
   - Guards the config body with `config = lib.mkIf cfg.enable result;`
4. Passes all module arguments (`config`, `lib`, `pkgs`, `options`, `settings`, `inputs`, etc.) through to the inner module via `@args`

### Usage
```nix
# home-manager/features/default.nix
{ inputs, ... }:
let
  mkFeatureImports = import "${inputs.self}/lib/mkFeatureImports.nix";
in
{
  imports = mkFeatureImports ./.;
}
```

---

## scan-files.nix

Auto-import utility for discovering Nix modules from a single directory level.

### Purpose
Enables automatic module discovery without manually maintaining import lists. Used by `modules/nixpkgs-overlays.nix` to load custom overlays.

### Parameters
- **path** (string): Directory path to scan (e.g., `./overlays`)

### Return Value
Returns a list of file paths:
```nix
[ ./my-overlay.nix ./another.nix ... ]
```

### Filtering Logic
1. Excludes `default.nix`
2. Includes `.nix` files
3. Includes directories containing `default.nix`

### Usage Example
```nix
let
  scanFiles = import "${inputs.self}/lib/scan-files.nix";
in
{
  imports = scanFiles ./.;
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

---

## symlink-dir.nix

Recursively creates out-of-store symlinks for an entire directory tree.

### Purpose
When you need to symlink a whole directory (e.g., neovim config) as editable out-of-store links, `mkOutOfStoreSymlink` only handles single files and `inputs.self` with `recursive = true` copies into the read-only Nix store. This function bridges the gap: it walks a directory at eval time with `builtins.readDir` and emits one `mkOutOfStoreSymlink` entry per file, so the entire tree is editable without rebuild.

### Parameters
- **src** (path): Store path used at eval time to walk the directory tree via `builtins.readDir` (e.g., `"${inputs.self}/dotfiles/.config/nvim-lazyvim"`)
- **dst** (string): Runtime absolute path that symlinks will point to (e.g., `"${dotfiles}/.config/nvim-lazyvim"`)
- **prefix** (string): Key prefix in the resulting attribute set, corresponding to the path under `xdg.configFile` or `home.file` (e.g., `"nvim-lazyvim"`)
- **mkSymlink** (function): Typically `config.lib.file.mkOutOfStoreSymlink`

### Return Value
An attribute set suitable for merging into `xdg.configFile` or `home.file`:
```nix
{
  "nvim-lazyvim/init.lua".source = mkSymlink "~/.dotfiles/.config/nvim-lazyvim/init.lua";
  "nvim-lazyvim/lua/config/keymaps.lua".source = mkSymlink "...";
  # ... one entry per file
}
```

### Usage Example

Typically accessed via the `config.lib.dotfiles` convenience wrappers defined in `home-manager/home.nix`:
```nix
{
  # Recursively symlink an entire .config/<dir>/ directory
  xdg.configFile = config.lib.dotfiles.configDir "nvim-lazyvim";

  # Can also be merged with other configFile entries
  xdg.configFile = config.lib.dotfiles.configFiles [
    "bat/config"
  ] // config.lib.dotfiles.configDir "bat/themes";
}
```

Direct usage without the wrapper:
```nix
let
  symlinkDir = import "${inputs.self}/lib/symlink-dir.nix";
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in
{
  xdg.configFile = symlinkDir {
    mkSymlink = config.lib.file.mkOutOfStoreSymlink;
    src = "${inputs.self}/dotfiles/.config/nvim-lazyvim";
    dst = "${dotfiles}/.config/nvim-lazyvim";
    prefix = "nvim-lazyvim";
  };
}
```
