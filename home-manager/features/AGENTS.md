# FEATURES SUBTREE

## OVERVIEW
`home-manager/features/` is the reusable feature library for user environments; files here are auto-imported and exposed as `features.<name>.enable` options.

## WHERE TO LOOK
- Auto-import boundary: `home-manager/features/default.nix`.
- Directory scanner: `lib/scan-files.nix`.
- Preset bundles that consume features: `lib/features.nix`.
- Representative complex modules: `home-manager/features/tmux.nix`, `home-manager/features/git.nix`, `home-manager/features/neovim.nix`.

## CONVENTIONS
- Standard module shape is `options.features.<name>.enable = lib.mkEnableOption ...;` plus `config = lib.mkIf cfg.enable { ... };`.
- Feature filenames and option names stay lowercase-hyphenated unless a nested namespace already defines the boundary.
- New top-level `.nix` files in this directory are picked up automatically; do not add them to a manual import list.
- Nested feature namespaces are allowed only through subdirectories with `default.nix`; current example: `fonts/source-han.nix` -> `features.fonts.source-han.enable`.
- Put reusable package/program setup here; host-only tweaks belong in `hosts/<name>/home.nix`.
- Update `lib/features.nix` only when the new feature should join a preset like `base`, `develop`, `console`, or `desktop`.
- Follow existing patterns for platform guards, usually `builtins.match ".*-darwin" settings.system != null`.

## ANTI-PATTERNS
- Do not create a feature module without an enable option.
- Do not edit `home-manager/features/default.nix` for routine feature additions; scanning already handles them.
- Do not add nested directories unless there is a real namespace need; keep the default shape flat.
- Do not put host-specific package lists or machine-only secrets here.

## NOTES
- Most modules are small; large modules should justify themselves with reusable logic, not one-off host customization.
- Dotfile-backed modules must keep their referenced `dotfiles/` paths accurate.
- Validate feature changes with `nix flake check`, then dry-build at least one host that enables the feature.
