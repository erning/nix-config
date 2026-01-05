# System Modules

Shared system-level configuration modules imported by `mkSystem` for all hosts.

## Module Import Order

Modules are imported in this order by `modules/system.nix`:

1. **nix-settings.nix** - Nix daemon configuration
2. **nixpkgs-config.nix** - Nixpkgs options
3. **nixpkgs-overlays.nix** - Custom package overlays
4. **darwin.nix** or **nixos.nix** - Platform-specific (conditional)
5. **packages.nix** - System-wide packages
6. **secrets.nix** - Agenix integration

---

## modules/system.nix

Base system configuration module that imports all other modules and sets defaults.

### Purpose
Central entry point for system configuration, handling platform detection and common defaults.

### Platform Detection
```nix
isDarwin = builtins.match ".*-darwin" settings.system != null;
```
Uses regex to determine if running on macOS, then conditionally imports `darwin.nix` or `nixos.nix`.

### Default Configuration
- **Shells**: Enables bash, fish, zsh for all platforms
- **Editor**: Sets `EDITOR` and `VISUAL` to `vim`
- **OpenSSH**: Enabled by default with `lib.mkDefault`
- **Root SSH**: Authorizes a specific SSH key for root access
- **Hostname**: Sets `networking.hostName` to `${settings.host}`
- **Timezone**: Defaults to "Asia/Shanghai"

---

## modules/darwin.nix

macOS-specific system configuration for nix-darwin.

### Purpose
Configures macOS system defaults, keyboard, dock, and other platform-specific settings.

### Configuration Options

#### System State
- `system.stateVersion = 6`: Required for nix-darwin to track changes

#### Shells
- Enables fish, bash, zsh (redundant with system.nix but explicit for Darwin)

#### Hostname
- Sets both `networking.computerName` and `system.defaults.smb.NetBIOSName` to `${settings.host}`

#### Trackpad
- `Clicking`: Enable tap-to-click
- `Dragging`: Enable drag gestures

#### Dock
- `autohide`: Automatically hide dock
- `show-recents`: Don't show recently used apps

#### Keyboard
- `enableKeyMapping`: Enable custom key mappings
- `remapCapsLockToControl`: Remap Caps Lock to Control key

### Note on Activation Scripts
Commented out `system.activationScripts.postUserActivation` - this option has been removed from nix-darwin. Settings now apply automatically on activation.

---

## modules/nixos.nix

NixOS-specific system configuration.

### Purpose
Configures Linux-specific settings including locale, SSH security, networking, and firewall.

### Configuration Options

#### System State
- `system.stateVersion = "25.05"`: Required for NixOS to track state

#### Shells
- Enables fish, zsh (bash available but not explicitly enabled)

#### OpenSSH Settings (Security Considerations)
- `PasswordAuthentication = true` (default): Allows password login
  - **Recommendation**: Disable for production systems, use key-based auth only
- `PermitRootLogin = "yes"` (default): Allows root SSH login
  - **Recommendation**: Disable for production, use sudo from user account
- `authoriedKeysInHomedir = true`: Accept SSH keys from `~/.ssh/authorized_keys`

#### Sudo Configuration
- `wheelNeedsPassword = false`: Users in wheel group don't need password for sudo
  - **Security impact**: Reduces security but improves convenience for personal use

#### Networking
- `firewall.enable = false`: Firewall disabled by default
  - **Recommendation**: Enable for systems exposed to internet
- `networkmanager.enable = true`: Uses NetworkManager for network configuration

#### Locale
- `defaultLocale = "en_US.UTF-8"`
- `extraLocaleSettings`: Sets all LC_* variables to en_US.UTF-8

---

## modules/nix-settings.nix

Nix daemon configuration and performance settings.

### Purpose
Enables flakes (experimental feature) and configures binary caches.

### Configuration Options

#### Experimental Features
- `experimental-features = "nix-command flakes"`: Enables modern Nix CLI and flakes
  - Required for flake-based configuration

#### Binary Substitutes (Caches)
Uses Chinese mirrors for faster downloads:
- `mirrors.ustc.edu.cn/nix-channels/store`
- `mirrors.tuna.tsinghua.edu.cn/nix-channels/store`

#### Download Buffer
- `download-buffer-size = 67108864` (64 MB): Buffer size for parallel downloads

### Why These Caches?
Chinese mirrors provide faster download speeds in China region. Remove or adjust if located elsewhere.

---

## modules/nixpkgs-config.nix

Nixpkgs configuration options.

### Purpose
Allows installation of unfree (proprietary) packages.

### Configuration Options
- `allowUnfree = true`: Permits installation of non-free packages

### Why Allow Unfree?
Some packages (e.g., VS Code, proprietary drivers, certain tools) are not free software and require this setting.

### Common Unfree Packages
- Visual Studio Code
- Discord
- Steam
- Nvidia drivers
- Certain fonts or proprietary software

---

## modules/nixpkgs-overlays.nix

Custom package overlays and unstable/stable channel access.

### Purpose
Provides access to multiple nixpkgs channels and loads custom overlays from `overlays/` directory.

### Built-in Overlays

#### unstable
```nix
unstable = import inputs.nixpkgs-unstable {
  inherit (final.stdenv.hostPlatform) system;
  inherit (final) config;
};
```
Allows access to `pkgs.unstable` anywhere in configuration.

#### stable
```nix
stable = import inputs.nixpkgs-stable {
  inherit (final.stdenv.hostPlatform) system;
  inherit (final) config;
};
```
Allows access to `pkgs.stable` anywhere in configuration.

### Custom Overlays
Auto-loads all `.nix` files from `overlays/` directory using dynamic imports.

**Filtering Logic**:
- Includes files matching `.*\.nix` pattern
- Includes directories containing `default.nix`

### Usage Example
```nix
home.packages = with pkgs; [
  (unstable.package-name)  # Use latest version from unstable
  (stable.other-package)     # Use stable version
];
```

---

## modules/packages.nix

System-wide package installation.

### Purpose
Installs essential packages available on all hosts at system level (not user-specific).

### Installed Packages
- **vim**: Text editor
- **git**: Version control
- **openssh**: SSH client and server

### Why System vs User Packages?
- **System packages** (`environment.systemPackages`): Available to all users, installed system-wide
- **User packages** (`home.packages`): Per-user, managed by home-manager
- Base tools like vim and git are available even before home-manager activation

---

## modules/secrets.nix

Agenix integration for secrets management.

### Purpose
Manages encrypted secrets using age encryption, with automatic SSH host key conversion.

### Configuration Options

#### Platform-Specific Modules
```nix
agenixModules =
  if builtins.match ".*-darwin" settings.system != null then
    inputs.agenix.darwinModules.default
  else
    inputs.agenix.nixosModules.default;
```
Imports correct agenix modules for Darwin or NixOS.

#### System Packages
- **age**: Age encryption/decryption tool
- **ssh-to-age**: Converts SSH keys to age format
- **agenix**: Agenix CLI tool (from agenix flake)

#### Age Identity Paths
- `/etc/age/keys.txt`: Age private key (manual)
- `/etc/age/ssh_host_ed25519.txt`: Converted from SSH host key (automatic)

#### SSH Host Key Conversion
Activation script converts SSH host key to age format:
```bash
if [ -f /etc/ssh/ssh_host_ed25519_key ]; then
  mkdir -p /etc/age
  ${pkgs.ssh-to-age}/bin/ssh-to-age \
    -private-key \
    -i /etc/ssh/ssh_host_ed25519_key \
    -o /etc/age/ssh_host_ed25519.txt
fi
```
Runs on system activation if SSH host key exists.

### How Secrets Work

1. **Encryption**: Secrets are encrypted using `agenix` tool in separate `nix-secrets` repo
2. **Decryption**: During system activation, age decrypts secrets using identity paths
3. **Placement**: Decrypted secrets are placed at configured paths
4. **SSH Integration**: SSH host key auto-converted for system secrets

### Typical Usage in Host Configs
```nix
age.secrets."my-secret" = {
  file = "${inputs.secrets}/my-secret.age";
  path = "/etc/my-secret";
  mode = "600";
};
```

### Documentation
- [agenix GitHub](https://github.com/ryantm/agenix)
- [age encryption](https://github.com/FiloSottile/age)
