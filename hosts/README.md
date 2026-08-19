# Host Configurations

Human-facing reference for the machines under `hosts/`.
For subtree-specific editing rules and exceptions, see `hosts/AGENTS.md`.

## Host Inventory

| Host | System | Hardware | Role |
|------|--------|----------|------|
| `dragon` | `aarch64-darwin` | MacBook Pro 16" 2021 | primary macOS workstation |
| `dinosaur-macos` | `x86_64-darwin` | MacBook Pro 16" 2019 | Intel macOS workstation (`dinosaur` hostname) |
| `dinosaur` | `x86_64-linux` | MacBook Pro 16" 2019 | Omarchy + home-manager only |
| `phoenix` | `x86_64-linux` | MacBook Pro 17" 2010 | NixOS laptop |
| `pomelo` | `x86_64-linux` | MacBook Air 13" 2019 | Omarchy + home-manager only |
| `pterosaur` | `x86_64-linux` | MacBook Pro 15" 2016 | Ubuntu Server 26.04 LTS + home-manager only |
| `mango` | `x86_64-linux` | MacBook 12" 2015 | Ubuntu Desktop 26.04 LTS + home-manager only |
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
  presets = import "${inputs.self}/home-manager/presets.nix" { inherit lib; };
in
{
  features = lib.mkMerge [
    presets.core
  ];
}
```

Typical `flake.nix` host inventory entry:

```nix
{
  name = "<output-name>";
  host = "<hostname>";
  configName = "<config-directory>";
  system = "aarch64-darwin";
}
```

`host` defaults to `name`, and `configName` defaults to `host`. Set
`configName` only when the flake output and runtime hostname should load a
different directory below `hosts/`.

## Validation

```bash
# macOS hosts
darwin-rebuild build --flake .#<hostname>

# NixOS hosts
nixos-rebuild dry-build --flake .#<hostname>

# home-manager-only hosts
home-manager build --flake .#erning@<hostname>
```

## Practical Notes

- Desktop hosts usually use `presets.workstation` (or combine `presets.development` with `presets.graphical`).
- Linux and VM hosts usually use `presets.development` or combine `presets.core` and `presets.terminal` with targeted additions.
- `pterosaur` uses `presets.development` with `targets.genericLinux.enable` for its headless Ubuntu environment.
- `mango` uses `presets.workstation` with `targets.genericLinux.enable` for its Ubuntu desktop environment.
- `dinosaur`, `pomelo`, `pterosaur`, and `mango` are home-manager-only hosts; validate them with `home-manager build` rather than a system rebuild.
- `orbstack` is intentionally unusual: it imports OrbStack's `/etc/nixos/configuration.nix` only when that path exists, which avoids store-external absolute-path warnings/errors during evaluation on non-OrbStack machines.
- Output names, runtime hostnames, and configuration directories can differ: `dinosaur-macos` loads `hosts/dinosaur-macos/` with hostname `dinosaur`, while `orb-aarch64 -> orbstack` and `vm-aarch64 -> vmfusion` map output names to configuration directories.
- Mirror defaults (nix substituters, Homebrew mirror) are appended in shared modules via `extra-substituters`. Hosts can append more in `configuration.nix` or `home.nix`; see `modules/README.md` for details.

## Home-Manager-Only Hosts

For hosts like `dinosaur` and `pomelo` (Omarchy), `pterosaur` (Ubuntu Server), and `mango` (Ubuntu Desktop), the system Nix daemon is **not** managed by this flake. `modules/nix-settings.nix` does not apply, so the daemon's `/etc/nix/nix.conf` must be set up manually once before the flake's experimental-feature, mirror, and trusted-user assumptions hold.

One-time root setup on the machine:

```bash
sudo tee -a /etc/nix/nix.conf <<'EOF'
experimental-features = nix-command flakes
trusted-users = root erning
extra-substituters = https://mirrors.ustc.edu.cn/nix-channels/store?priority=10 https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=11
EOF
sudo systemctl restart nix-daemon
```

Notes:
- The `experimental-features` line enables the `nix` command and flakes used by this repository.
- `trusted-users` is required for the daemon to honor any further substituter requests coming from the user's nix.conf or flake `nixConfig`. Without it the daemon silently ignores them and keeps using only what's in `/etc/nix/nix.conf`.
- The `extra-substituters` line is what gives this host the same mirror behavior the flake-managed hosts get from `modules/nix-settings.nix`.
- `extra-trusted-public-keys` is not needed for ustc/tuna — they re-serve `cache.nixos.org`-signed NARs and the upstream key is already trusted by default.
- This is a one-time bootstrap. Re-running it is harmless (lines just append).

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
