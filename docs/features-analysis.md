# Home-Manager Features Analysis

Analysis of `home-manager/features/` modules for potential homebrew migration.

Classification criteria:
- **Packages-only**: Only uses `home.packages` to install packages, no configuration
- **Config-only**: Only does configuration (`programs.*`, `xdg.configFile`, `home.file`, etc.)
- **Both**: Installs packages AND provides configuration

> Note: Features using `programs.X.enable = true` implicitly install packages
> via home-manager's programs module. These are classified as "config-only"
> since the package install is a side-effect of the programs module, not an
> explicit `home.packages` entry.

---

## Packages-only (12)

Most suitable for homebrew migration - just replace with `brew install`.

| Feature | Packages |
|---|---|
| `zig.nix` | zig |
| `direnv.nix` | direnv |
| `python.nix` | python3, uv |
| `just.nix` | just |
| `docker.nix` | lazydocker |
| `rustup.nix` | rustup |
| `jdk.nix` | jdk |
| `kotlin.nix` | kotlin |
| `gradle.nix` | gradle |
| `nix-support.nix` | nil, nixd, nixfmt |
| `build-essential.nix` | bison, flex, fontforge, makeWrapper, pkg-config, gnumake, gcc, libiconv, autoconf, automake, libtool |
| `typst.nix` | typst (+ conditional fonts if fonts feature enabled) |

## Config-only (13)

No explicit `home.packages`. If packages are installed via homebrew, these
configurations can remain in nix.

### Pure symlink/config (no implicit package install)

These truly install nothing - they only symlink dotfiles or configure settings.

| Feature | Configuration |
|---|---|
| `ssh.nix` | programs.ssh (matchBlocks, includes), home.file (authorized_keys, conf.d) |
| `zed.nix` | xdg.configFile (settings.json symlink) |
| `ghostty.nix` | xdg.configFile (config symlink) |
| `kitty.nix` | xdg.configFile (kitty.conf, current-theme.conf, kitty.app.png) |
| `alacritty.nix` | xdg.configFile (alacritty.toml symlink) |

### programs.X.enable (implicit package install)

These use `programs.X.enable = true` which implicitly installs the package.
If migrating the package to homebrew, change to config-only mode by removing
`enable = true` and setting `package = null` or similar.

| Feature | Implicit Package | Configuration |
|---|---|---|
| `fish.nix` | fish | programs.fish.enable only |
| `bash.nix` | bash | programs.bash.enable only |
| `zsh.nix` | zsh | programs.zsh + custom dotDir |
| `nushell.nix` | nushell | programs.nushell.enable only |
| `eza.nix` | eza | programs.eza (git, icons settings) |
| `fzf.nix` | fzf | programs.fzf + shell integrations (zsh, fish, bash) |
| `zoxide.nix` | zoxide | programs.zoxide + shell integrations (zsh, fish, bash, nushell) |
| `bat.nix` | bat | programs.bat + xdg.configFile (config, themes) |

## Both (10)

Install packages AND provide configuration. Migration requires splitting:
keep config in nix, move package install to homebrew.

| Feature | Explicit Packages | Implicit Packages | Configuration |
|---|---|---|---|
| `git.nix` | git, git-lfs, git-crypt, delta, lazygit | - | xdg.configFile (git config, darwin.gitconfig, catppuccin theme, lazygit config) |
| `neovim.nix` | neovim | - | xdg.configFile (LazyVim), home.file (lazyvim script), sessionVariables (EDITOR, VISUAL), shell aliases (vi) |
| `vim.nix` | vim | - | home.file (.vim/vimrc, plugins: catppuccin, polyglot, editorconfig, lightline) |
| `nodejs.nix` | nodejs_24, pnpm, bun | - | home.file (.npmrc symlink) |
| `go.nix` | go | - | programs.go (GOPATH) |
| `zellij.nix` | zellij | - | xdg.configFile (config.kdl symlink) |
| `fonts.nix` | libertine, lxgw-wenkai, lxgw-neoxihei, nerd-fonts.jetbrains-mono, nerd-fonts._0xproto, font-awesome, nerd-fonts.symbols-only | - | fonts.fontconfig.enable |
| `starship.nix` | - | starship (unstable) | programs.starship + shell integrations + xdg.configFile (config symlink) |
| `tmux.nix` | - | tmux | programs.tmux (prefix, vi-mode, mouse, keybindings, Catppuccin theme, status line) |
| `yazi.nix` | - | yazi | programs.yazi + shell integrations + xdg.configFile (theme, Catppuccin) |

---

## Migration Guide

### Tier 1: Easiest (Packages-only)

Direct `brew install` replacement. Remove from nix entirely.

```
brew install zig direnv python uv just lazydocker rustup jdk kotlin gradle typst
```

Exceptions:
- **nix-support.nix** (nil, nixd, nixfmt) - Nix ecosystem tools, may not be in homebrew or have different versions. Consider keeping in nix.
- **build-essential.nix** - Many of these are macOS system tools or available via Xcode CLI tools. Review individually.

### Tier 2: Config-only with implicit packages

For features using `programs.X.enable`, if package moves to homebrew:
1. Keep the nix module for configuration
2. Set `programs.X.package = pkgs.emptyDirectory` or equivalent to prevent nix from installing the package
3. Ensure homebrew-installed binary is on PATH

Candidates: eza, fzf, zoxide, bat, fish, bash, zsh, nushell

### Tier 3: Both (requires splitting)

1. Move package install to homebrew
2. Keep configuration in nix (xdg.configFile, home.file, etc.)
3. For `programs.X` based ones (starship, tmux, yazi), also need the package override trick from Tier 2

### Keep in nix

- **Pure symlink features** (zed, ghostty, kitty, alacritty, ssh) - these are config-only and work regardless of how the package is installed
- **Complex config features** (tmux, neovim) - extensive nix-managed configuration that would be hard to replicate outside nix
