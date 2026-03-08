# Package Overlays

This directory is reserved for custom nixpkgs overlays.

## Current State

- There are currently no custom overlays here.
- The directory is kept in git with `.keep` so overlays can be added later without changing the loader pattern.
- `pkgs.stable` and `pkgs.unstable` are already provided by `modules/nixpkgs-overlays.nix`; that behavior does not depend on files in this directory.

## How Loading Works

`modules/nixpkgs-overlays.nix` automatically imports:

- any `*.nix` file under `overlays/`
- any subdirectory that contains `default.nix`

That means adding `overlays/my-overlay.nix` is enough to make it available on the next evaluation.

## Minimal Overlay Shape

```nix
final: prev: {
  my-package = prev.callPackage ./path/to/package.nix { };
}
```

## Validation

```bash
nix flake check
nix build .#legacyPackages.x86_64-darwin.my-package --dry-run
```

If multiple overlays exist later, keep them small and focused so ordering stays easy to reason about.

## Related Docs

- `modules/README.md` - shared module behavior
- [Nixpkgs overlays manual](https://nixos.org/manual/nixpkgs/unstable/#chap-overlays)
