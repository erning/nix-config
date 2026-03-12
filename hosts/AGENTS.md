# HOSTS SUBTREE

## OVERVIEW
`hosts/` holds per-machine overrides that plug into the shared builder flow from `flake.nix`.

## WHERE TO LOOK
- New host wiring: `flake.nix` plus `hosts/<name>/configuration.nix` and `hosts/<name>/home.nix`.
- NixOS host boot or user setup: `hosts/<name>/configuration.nix`.
- Host-specific feature mix, packages, or SSH imports: `hosts/<name>/home.nix`.
- Auto-generated hardware details: `hosts/<name>/hardware-configuration.nix` on NixOS machines only.

## CONVENTIONS
- Standard host layout is a pair: `configuration.nix` for system settings, `home.nix` for home-manager settings.
- `pomelo` is the exception: home-manager only, no `configuration.nix`.
- `orbstack` is the exception on the system side: it imports `/etc/nixos/configuration.nix` and forces hostname.
- Host homes usually import `home-manager/presets.nix` and compose presets with `lib.mkMerge`.
- Keep host-specific changes local here; shared behavior belongs in `modules/` or `home-manager/features/`.

## ANTI-PATTERNS
- Do not add a host directory without also wiring the matching outputs in `flake.nix`.
- Do not treat flake output names and host directory names as always identical; `orb-aarch64 -> orbstack` and `vm-aarch64 -> vmfusion` are deliberate mappings.
- Do not edit `hardware-configuration.nix` casually; it is generated state, not a style file.
- Do not duplicate shared module logic here when the change should apply to multiple hosts.

## NOTES
- Desktop Darwin hosts usually use `presets.workstation` (or combine `presets.development` with `presets.graphical`).
- Linux and VM hosts tend to use `presets.development` or combine `presets.core` and `presets.terminal` with targeted additions.
- Validate host edits with the host-appropriate dry build: `darwin-rebuild build --flake .#<host>` or `nixos-rebuild dry-build --flake .#<host>`.
- See `hosts/README.md` for the longer human-oriented setup guide.
