# Package Overlays

Custom package overlays and modifications to nixpkgs.

## Purpose

Overlays allow you to:
- Add custom packages not in nixpkgs
- Modify existing packages (apply patches, change dependencies)
- Access multiple nixpkgs channels (stable, unstable)

## Directory Structure

```
overlays/
└── .keep    # Keeps directory in git (empty)
```

**Note**: Currently no custom overlays are defined. All overlays are auto-loaded from this directory.

## Auto-Loading Mechanism

Overlays in this directory are automatically loaded by `modules/nixpkgs-overlays.nix`:

```nix
# In modules/nixpkgs-overlays.nix
++ (
  let
    path = "${inputs.self}/overlays";
  in
  with builtins;
  map (n: import path + ("/" + n)) (
    filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
      attrNames (readDir path)
      )
    )
  )
```

**File Matching**:
- Files ending in `.nix`
- Directories containing `default.nix`

## Built-in Overlays

The following overlays are defined in `modules/nixpkgs-overlays.nix`:

### unstable

Provides access to `pkgs.unstable` for latest package versions:

```nix
unstable = import inputs.nixpkgs-unstable {
  inherit (final.stdenv.hostPlatform) system;
  inherit (final) config;
};
```

**Usage**:
```nix
home.packages = with pkgs; [
  unstable.rust-analyzer   # Latest version from unstable
  stable.neovim          # Stable version
];
```

### stable

Provides access to `pkgs.stable` for stable package versions:

```nix
stable = import inputs.nixpkgs-stable {
  inherit (final.stdenv.hostPlatform) system;
  inherit (final) config;
};
```

**Usage**:
```nix
home.packages = with pkgs; [
  stable.vim              # Stable version from 25.05
  unstable.rustc         # Latest from unstable
];
```

## Creating a Custom Overlay

### 1. Create Overlay File

Create `overlays/<name>.nix`:

```nix
# overlays/my-package.nix
final: prev: {
  # Example: Add a custom package
  my-package = prev.callPackage ./path/to/package.nix { };

  # Example: Modify existing package
  existing-package = prev.existing-package.override {
    someOption = "value";
  };

  # Example: Apply patches
  existing-package = prev.existing-package.overrideAttrs (old: {
    patches = [
      ./path/to/patch.diff
      (prev.fetchpatch {
        url = "https://example.com/patch.diff";
        sha256 = "sha256-...";
      })
    ];
  });
}
```

### 2. Overlay Signature

Overlay function signature:

```nix
final: prev: {
  # final: The final package set (includes all overlays)
  # prev: The previous package set (before this overlay)

  # Return modified package set
}
```

### 3. Package Set Structure

The package set (`prev`) contains all packages from nixpkgs and previous overlays:

```nix
{
  # Access packages
  my-package = prev.callPackage ...;
  existing-package = prev.existing-package;

  # Use stdenv
  stdenv = prev.stdenv;

  # Use fetchers
  fetchFromGitHub = prev.fetchFromGitHub;
  fetchurl = prev.fetchurl;
}
```

### 4. Apply Automatically

Save as `overlays/my-overlay.nix` - it will be auto-loaded on next rebuild.

## Overlay Examples

### Adding a Custom Package

```nix
# overlays/my-tool.nix
final: prev:
{
  my-tool = prev.stdenv.mkDerivation {
    pname = "my-tool";
    version = "1.0.0";
    src = ./src/my-tool;
    buildPhase = ''
      gcc my-tool.c -o my-tool
      cp my-tool $out/bin/
    '';
  };
}
```

### Patching a Package

```nix
# overlays/patched-package.nix
final: prev:
{
  patched-package = prev.some-package.overrideAttrs (old: {
    patches = [
      (prev.fetchpatch {
        url = "https://example.com/fix.patch";
        sha256 = "sha256-...";
      })
      ./local/fix.diff
    ];
  });
}
```

### Changing Dependencies

```nix
# overlays/dependency-fix.nix
final: prev:
{
  my-package = prev.my-package.override {
    dependency = prev.newer-dependency;
  };
}
```

### Complex Overlay with Multiple Changes

```nix
# overlays/comprehensive.nix
final: prev:
{
  # Multiple modifications in one overlay
  package1 = prev.package1.override { ... };
  package2 = prev.package2.overrideAttrs (old: {
    patches = [ ... ];
  });

  # Add completely new packages
  new-package = prev.callPackage ./packages/new-package.nix { };
}
```

## Testing Overlays

### Dry Run

```bash
# Build a specific package from overlay
nix build .#legacyPackages.x86_64-darwin.my-package --dry-run

# Show derivation path
nix build .#legacyPackages.x86_64-darwin.my-package
```

### Verification

```bash
# Enter shell with overlay available
nix develop

# Check if package is available
nix eval .#legacyPackages.x86_64-darwin.my-package.meta.description

# List packages in overlay
nix eval .#legacyPackages.x86_64-darwin --apply 'pkgs: builtins.attrNames pkgs' | jq .
```

## Overlay Priority

Overlays are applied in order:

1. Built-in overlays (unstable, stable)
2. Custom overlays from `overlays/` directory (alphabetical order)

Later overlays can override earlier ones.

### Changing Order

To control overlay order, use explicit ordering in `flake.nix`:

```nix
{
  nixpkgs.overlays = [
    # Explicit list of overlays
    (import ./overlays/overlay1.nix)
    (import ./overlays/overlay2.nix)
  ];
}
```

## Troubleshooting

### Overlay Not Found

**Error**: `error: undefined variable 'my-package'`

**Solution**:
- Check overlay file exists in `overlays/`
- Verify file ends in `.nix`
- Check overlay syntax with `nix flake check`

### Conflicting Overlays

**Issue**: Multiple overlays modifying the same package

**Solution**:
- Use specific overlay names in your code: `pkgs.my-custom-overlay.package-name`
- Be aware of overlay ordering
- Test which overlay is being used: `nix build .#legacyPackages.x86_64-darwin.package-name --show-trace`

### Circular Dependencies

**Error**: `error: infinite recursion detected`

**Solution**:
- Ensure overlay doesn't reference itself
- Check package dependency chain
- Use `prev.` to access base packages, not final.

## Related Documentation

- [Nixpkgs Overlays](https://nixos.org/manual/nixpkgs/unstable/#chap-overlays)
- [Nixpkgs Contribution Guide](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)
- [modules/nixpkgs-overlays.nix](../modules/README.md#modulesnixpkgs-overlaysnix) - Overlay loader
