# Host Configurations

Human-facing reference for the machines under `hosts/`.
For subtree-specific editing rules and exceptions, see `hosts/AGENTS.md`.

## Host Inventory

| Host | System | Hardware | Role |
|------|--------|----------|------|
| `dragon` | `aarch64-darwin` | MacBook Pro 16" 2021 | primary macOS workstation |
| `dinosaur` | `x86_64-darwin` | MacBook Pro 16" 2019 | Intel macOS workstation |
| `phoenix` | `x86_64-linux` | MacBook Pro 17" 2010 | NixOS laptop |
| `pomelo` | `x86_64-linux` | MacBook Air 13" 2019 | Fedora + home-manager only |
| `pterosaur` | `x86_64-darwin` | MacBook Pro 15" 2016 | Intel macOS workstation |
| `mango` | `x86_64-darwin` | MacBook 12" 2015 | lightweight macOS host |
| `orbstack` | `aarch64-linux` | OrbStack VM | NixOS VM using external `/etc/nixos/configuration.nix` |
| `vmfusion` | `aarch64-linux` | VMware Fusion VM | NixOS VM |

## Common Files

- `hosts/<name>/configuration.nix`: system-level overrides merged into the shared module stack.
- `hosts/<name>/home.nix`: host-specific home-manager feature selection, packages, and user overrides.
- `hosts/<name>/hardware-configuration.nix`: generated NixOS hardware file present only on some Linux hosts.

## Adding a New Host

1. Create `hosts/<hostname>/`.
2. Add `configuration.nix` if the machine is managed by NixOS or nix-darwin.
3. Add `home.nix` for the user environment.
4. Register both outputs in `flake.nix` using `mkSystem` and `mkHome`.
5. Dry-build before switching.

Minimal `home.nix`:

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

Typical `flake.nix` wiring:

```nix
darwinConfigurations.<hostname> = mkSystem {
  host = "<hostname>";
  system = "aarch64-darwin";
};

homeConfigurations."erning@<hostname>" = mkHome {
  user = "erning";
  host = "<hostname>";
  system = "aarch64-darwin";
};
```

## Validation

```bash
# macOS hosts
darwin-rebuild dry-build --flake .#<hostname>

# NixOS hosts
nixos-rebuild dry-build --flake .#<hostname>

# home-manager-only hosts
home-manager switch --flake .#erning@<hostname> --dry-run
```

## Practical Notes

- Desktop Darwin hosts usually combine `features.develop` and `features.desktop`.
- Linux and VM hosts usually combine `features.console` with targeted additions.
- `pomelo` is the home-manager-only host; validate it with the home-manager dry run rather than a system rebuild.
- `orbstack` is intentionally unusual: it imports `/etc/nixos/configuration.nix`, so evaluation depends on that external file existing on the machine running the command.
- Flake output names do not always match directory names: `orb-aarch64 -> orbstack` and `vm-aarch64 -> vmfusion`.
- Mirror defaults (nix substituters, Homebrew mirror) are set with `lib.mkDefault` in shared modules. Override per-host in `configuration.nix` or `home.nix`; see `modules/README.md` for details.

## Troubleshooting

### Host not found in flake

If `.#<hostname>` or `.#erning@<hostname>` is missing, confirm the matching outputs were added in `flake.nix`.

### Configuration not taking effect

1. Run `nix flake check` if the target host supports pure evaluation.
2. Run the host-appropriate dry build.
3. Re-run the switch command after the dry build succeeds.

### Platform mismatch

Double-check the `system` string in `flake.nix`:

- macOS Apple Silicon: `aarch64-darwin`
- macOS Intel: `x86_64-darwin`
- Linux Apple Silicon VM: `aarch64-linux`
- Linux Intel: `x86_64-linux`

## Related Documentation

- `hosts/AGENTS.md` - subtree-specific editing rules
- `lib/README.md` - `mkSystem` and `mkHome` details
- `modules/README.md` - shared system module behavior
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
