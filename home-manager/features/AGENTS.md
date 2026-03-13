# FEATURES SUBTREE

## OVERVIEW
`home-manager/features/` is the reusable feature library for user environments; files here are auto-imported and exposed as `features.<name>.enable` options.

## WHERE TO LOOK
- Auto-import boundary: `home-manager/features/default.nix`.
- Auto-wrapper and recursive scanner: `lib/mkFeatureImports.nix`.
- Preset bundles that consume features: `home-manager/presets.nix`.
- Dotfile helper surface: `home-manager/home.nix` (`config.lib.dotfiles`).
- Representative complex modules: `home-manager/features/tmux.nix`, `home-manager/features/git.nix`, `home-manager/features/neovim.nix`.

## CONVENTIONS
- Feature files are plain config modules; `mkFeatureImports.nix` injects the enable option and `lib.mkIf` wrapper automatically.
- Module args are the usual Nix module args (`config`, `lib`, `pkgs`, `options`, `settings`, `inputs`, ...); only declare the ones the file needs.
- Feature filenames and option names stay lowercase-hyphenated unless a nested namespace already defines the boundary.
- New `.nix` files anywhere under this directory are picked up automatically; do not add them to a manual import list.
- Subdirectories create nested namespaces directly; `default.nix` files are skipped rather than required. Current example: `fonts/source-han.nix` -> `features.fonts.source-han.enable`.
- Put reusable package/program setup here; host-only tweaks belong in `hosts/<name>/home.nix`.
- Update `home-manager/presets.nix` only when the new feature should join a preset like `core`, `terminal`, `languages`, `devtools`, or `graphical`.
- Follow existing patterns for platform guards: use `settings.isDarwin` / `settings.isLinux`.
- Dotfile-backed features should usually use `config.lib.dotfiles.configFiles` / `homeFiles`; use `configDir` when the whole directory should stay recursively editable.

## ANTI-PATTERNS
- Do not hand-write `options.features.*` boilerplate in routine feature files; the wrapper already does that.
- Do not edit `home-manager/features/default.nix` for routine feature additions; scanning already handles them.
- Do not add nested directories unless there is a real namespace need; keep the default shape flat.
- Do not put host-specific package lists or machine-only secrets here.
- Do not use `lib.mkIf` as a version guard for missing Home Manager options; use `lib.optionalAttrs (options.path ? attr) { ... }` instead.

## NOTES
- Most modules are small; large modules should justify themselves with reusable logic, not one-off host customization.
- Dotfile-backed modules must keep their referenced `dotfiles/` paths accurate; the feature module is the source of truth for mount points.
- If the payload is static and should come from the repo store path, `inputs.self` with `recursive = true` is acceptable; if you would edit it in place, prefer the dotfile symlink helpers.
- Validate feature changes with `nix flake check` when pure evaluation is available, then run `home-manager build --flake .#erning@<host>` or dry-build a host that enables the feature.
