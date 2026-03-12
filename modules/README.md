# System Modules

Shared system-level configuration modules imported by `mkSystem` for all hosts.

## Module Import Order

Modules are imported in this order by `modules/system.nix`:

1. **nix-settings.nix** - Nix daemon configuration (flakes, binary caches)
2. **nixpkgs-config.nix** - `allowUnfree = true`
3. **nixpkgs-overlays.nix** - `pkgs.unstable`/`pkgs.stable` access + auto-loaded overlays from `overlays/`
4. **darwin.nix** or **nixos.nix** - platform-specific (conditional)
5. **packages.nix** - system-wide packages (vim, git, openssh)
6. **secrets.nix** - agenix integration

## Module Summaries

**system.nix** - Central entry point. Detects platform, imports the platform-specific module, sets defaults (shells, editor, timezone, hostname, SSH).

**darwin.nix** - macOS defaults: tap-to-click, dock autohide, Caps Lock remapped to Control, state version.

**nixos.nix** - NixOS defaults: locale (en_US.UTF-8), NetworkManager, passwordless sudo for wheel, firewall disabled, SSH with password auth, state version.

**nix-settings.nix** - Enables flakes, configures Chinese mirror substituters with `lib.mkDefault`. Override per-host:

```nix
# hosts/<hostname>/configuration.nix
{
  nix.settings.substituters = [ "https://cache.nixos.org" ];
}
```

**nixpkgs-overlays.nix** - Provides `pkgs.unstable` and `pkgs.stable` overlays plus auto-loads `.nix` files from `overlays/`.

**secrets.nix** - Imports platform-appropriate agenix module, installs age/ssh-to-age/agenix, converts SSH host key to age format on activation.
