# Home-Manager Features Analysis

Analysis of all `home-manager/features/` modules (38 total).

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
| `nix-support.nix` | nil, nixd, nixfmt (nixfmt-rfc-style on the `"25.05"` channel) |
| `build-essential.nix` | bison, flex, fontforge, makeWrapper, pkg-config, gnumake, gcc, libiconv, autoconf, automake, libtool |
| `typst.nix` | typst (+ conditional fonts: libertinus, jetbrains-mono, newcomputermodern if fonts feature enabled) |

## Config-only (14)

No explicit `home.packages`.

### Pure symlink/config (no implicit package install)

These truly install nothing - they only symlink dotfiles or configure settings.

| Feature | Configuration |
|---|---|
| `ssh.nix` | programs.ssh (matchBlocks, includes, isDarwin conditional), home.file (authorized_keys, conf.d) |
| `zed.nix` | xdg.configFile (settings.json symlink) |
| `ghostty.nix` | xdg.configFile (config symlink) |
| `kitty.nix` | xdg.configFile (kitty.conf, current-theme.conf, kitty.app.png) |
| `alacritty.nix` | xdg.configFile (alacritty.toml symlink) |
| `opencode.nix` | xdg.configFile (opencode/opencode.json) |

### programs.X.enable (implicit package install)

These use `programs.X.enable = true` which implicitly installs the package.

| Feature | Implicit Package | Configuration |
|---|---|---|
| `fish.nix` | fish | programs.fish.enable only |
| `bash.nix` | bash | programs.bash.enable only |
| `zsh.nix` | zsh | programs.zsh + custom dotDir |
| `nushell.nix` | nushell | programs.nushell.enable only |
| `eza.nix` | eza | programs.eza (git, icons settings) |
| `fzf.nix` | fzf | programs.fzf + shell integrations (zsh, fish, bash) |
| `zoxide.nix` | zoxide | programs.zoxide + shell integrations (zsh, fish, bash, nushell) |
| `bat.nix` | bat | programs.bat + xdg.configFile (config symlink, themes via inputs.self) |

## Both (12)

Install packages AND provide configuration.

| Feature | Explicit Packages | Implicit Packages | Configuration |
|---|---|---|---|
| `git.nix` | git, git-lfs, git-crypt, delta, lazygit | - | xdg.configFile (git/config, git/config.local, git/catppuccin.gitconfig, lazygit/config.yml), home.file (.gitignore_global) |
| `claude-code.nix` | cce (fetched from github.com/erning/cce at v2.1.6 via fetchFromGitHub + runCommand) | - | xdg.configFile (cce/kimi.env, cce/minimax.env, cce/zhipu.env) |
| `neovim.nix` | neovim, nvim-profiles (lazyvim dispatcher via writeShellScriptBin + runCommand) | - | xdg.configFile (nvim-lazyvim/ via configDir), sessionVariables (EDITOR, VISUAL), shell aliases (vi) |
| `vim.nix` | vim | - | home.file (.vim/vimrc via symlink, plugins: catppuccin, polyglot, editorconfig, lightline) |
| `nodejs.nix` | nodejs_24, pnpm, bun | - | home.file (.npmrc symlink) |
| `go.nix` | go | - | programs.go (GOPATH via optionalAttrs guard) |
| `zellij.nix` | zellij | - | xdg.configFile (config.kdl symlink) |
| `fonts.nix` | libertine, lxgw-wenkai, lxgw-neoxihei, nerd-fonts.jetbrains-mono, nerd-fonts._0xproto, font-awesome, nerd-fonts.symbols-only (unstable) | - | fonts.fontconfig.enable |
| `fonts/source-han.nix` | source-han-sans, source-han-serif, source-han-mono (unstable) | - | - |
| `starship.nix` | - | starship (unstable, explicit package override) | programs.starship + shell integrations + xdg.configFile (starship.toml symlink) |
| `tmux.nix` | - | tmux | programs.tmux (prefix, vi-mode, mouse, keybindings, tmux-256color terminal, historyLimit 50000, focus-events, renumber-windows, copy-mode-vi bindings, Catppuccin theme v2.3.0) |
| `yazi.nix` | - | yazi | programs.yazi + shell integrations + xdg.configFile (theme.toml symlink, Catppuccin-mocha.tmTheme via inputs.self) |

---

## Preset Membership

| Preset | Features |
|---|---|
| **core** | fish, bash, zsh, starship, eza, fzf, bat, vim, git, ssh |
| **terminal** | tmux, neovim, nushell, zellij, zoxide, yazi |
| **languages** | rustup, zig, python, go, nodejs, jdk, kotlin |
| **devtools** | nix-support, just, direnv, gradle, typst, docker, claude-code, opencode |
| **graphical** | fonts, fonts.source-han, zed, ghostty, kitty, alacritty |
| **development** | core + terminal + languages + devtools |
| **workstation** | development + graphical |

## Special Patterns

| Pattern | Features |
|---|---|
| `settings.isDarwin` | ssh.nix (conditional OrbStack SSH config include) |
| `lib.optionalAttrs` (version guard) | go.nix (`programs.go.env`), ssh.nix (`programs.ssh.enableDefaultConfig`) |
| `pkgs.unstable` | fonts.nix, fonts/source-han.nix, starship.nix |
| `inputs.self` (store path) | bat.nix (themes dir), yazi.nix (Catppuccin tmTheme) |
| `configDir` (recursive symlink) | neovim.nix (nvim-lazyvim/) |
| Feature cross-reference | typst.nix (reads `config.features.fonts.enable` for conditional font packages) |
