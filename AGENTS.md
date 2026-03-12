# PROJECT KNOWLEDGE BASE

## OVERVIEW
Personal NixOS and nix-darwin flake for one user across macOS, Linux, VMs, and home-manager-only hosts.
Core architecture is builder-driven: `flake.nix` wires hosts through `lib/mkSystem.nix` and `lib/mkHome.nix`, then shared modules and host overrides do the rest.

## STRUCTURE
```text
nix-config/
|- flake.nix              # all host and home entrypoints
|- lib/                   # mkSystem, mkHome, mkFeatureImports
|- modules/               # shared system modules and overlays/secrets wiring
|- home-manager/          # base HM config plus auto-imported features
|- hosts/                 # per-host configuration.nix + home.nix pairs
|- dev-shells/            # standalone dev shell flakes
|- dotfiles/              # app configs referenced by feature modules
`- overlays/              # custom overlays auto-loaded when present
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Add or rename a host | `flake.nix`, `hosts/` | add both flake outputs and host files |
| Change shared system behavior | `modules/` | imported by every `mkSystem` host |
| Change shared user environment | `home-manager/home.nix`, `home-manager/features/` | features are auto-imported |
| Adjust default feature bundles | `home-manager/presets.nix` | presets are merged in host `home.nix` |
| Change builder flow | `lib/mkSystem.nix`, `lib/mkHome.nix` | keep import order intact |
| Update symlinked app config | `dotfiles/` plus owning feature module | paths in features must stay aligned |
| Change dotfile wiring helpers | `home-manager/home.nix`, `lib/symlink-dir.nix` | `config.lib.dotfiles` is the public helper surface |

## CODE MAP
| File | Role |
|------|------|
| `flake.nix` | root inventory of darwin, nixos, and home-manager configs; pins legacy macOS hosts to nixpkgs-2505 |
| `lib/mkSystem.nix` | imports `modules/system.nix` + `hosts/<host>/configuration.nix`; reused by pinned builders |
| `lib/mkHome.nix` | imports nixpkgs config, overlays, `home-manager/home.nix`, host home; reused by pinned builders |
| `home-manager/presets.nix` | non-overlapping building blocks (`core`, `terminal`, `languages`, `devtools`, `graphical`) and composites (`development`, `workstation`) |
| `lib/mkFeatureImports.nix` | recursive scanner + auto-wrapper for feature modules; derives name from filename, adds enable option + mkIf |
| `lib/symlink-dir.nix` | recursive out-of-store symlink helper used by `config.lib.dotfiles.configDir` |
| `lib/scan-files.nix` | dynamic loader for overlay directories |
| `modules/system.nix` | shared system module import order |
| `home-manager/home.nix` | base HM layer; defines `config.lib.dotfiles` helpers and imports platform modules + features |
| `home-manager/features/default.nix` | auto-import boundary; delegates to `mkFeatureImports` |

## CONVENTIONS
- Nix formatting: 2-space indent, LF, UTF-8, final newline, trimmed trailing whitespace.
- Naming: hosts and features are lowercase-hyphenated; local variables are camelCase.
- Platform checks use `builtins.match ".*-darwin" ... != null`.
- New feature files under `home-manager/features/` become available automatically through `lib/mkFeatureImports.nix`. Subdirectories create nested features (e.g., `fonts/source-han.nix` → `features.fonts.source-han`).
- Feature modules are pure config functions — no boilerplate needed. `mkFeatureImports` auto-wraps each file with `options.features.<name>.enable` and `lib.mkIf`. Use `_description = "...";` in the returned attrset to override the default mkEnableOption description (which is the filename-derived name).
- Host homes usually compose presets with `lib.mkMerge [ presets.<name> ... ]`.
- Dotfile helpers live in `config.lib.dotfiles`: use `configFiles` for XDG files, `homeFiles` for home-level files, `configDir` for recursive editable directories, and `symlink` for one-off paths.
- Legacy macOS hosts (`pterosaur`, `mango`) use pinned `mkSystem-2505`/`mkHome-2505` builders backed by nixpkgs-25.05 inputs.
- Feature modules that use options not present in all home-manager versions must guard them with `lib.optionalAttrs (options.path ? attr) { ... }` so the attribute path is absent entirely when the option does not exist; `lib.mkIf` only wraps the value and still exposes the path to the module system (see `go.nix`).
- Shared abstractions are intentionally thin; most behavior lives in small Nix modules rather than large helper layers.
- Presets in `home-manager/presets.nix` are non-overlapping building blocks composed into `development` and `workstation` composites; all values use `lib.mkDefault`, then hosts opt in with `lib.mkMerge`.
- This repo mixes declarative Nix modules with out-of-store dotfile symlinks for tools like git and lazygit.

## ANTI-PATTERNS
- Do not bypass `mkSystem` or `mkHome` when adding hosts; `flake.nix` should stay on the builder path.
- Do not hand-maintain feature import lists inside `home-manager/features/`; the directory is scanned automatically.
- Do not edit `hosts/*/hardware-configuration.nix` unless the task is explicitly hardware-generation work.
- Do not move or rename files under `dotfiles/` without updating the feature modules that reference them.
- Do not touch secret material, encrypted files, or private-key-like files unless the task explicitly requires it.

## COMMANDS
```bash
nix flake check
darwin-rebuild build --flake .#dragon
nixos-rebuild dry-build --flake .#phoenix
home-manager build --flake .#erning@dragon
```

## NOTES
- `hosts/orbstack/configuration.nix` is a special case that imports `/etc/nixos/configuration.nix`.
- `pomelo` is home-manager-only; it has no system `configuration.nix`.
- Flake output names do not always match host directories: `orb-aarch64 -> orbstack` and `vm-aarch64 -> vmfusion` are intentional.
- `pterosaur` (macOS Monterey 12.7.6) and `mango` (macOS Big Sur 11.7.10) are pinned to nixpkgs-25.05 / nix-darwin-25.05 / home-manager-25.05 because nixpkgs-unstable requires macOS Sonoma 14.0+.
- `nix flake check` is not pure-eval-safe on machines that do not have `/etc/nixos/configuration.nix` for `orbstack`.
