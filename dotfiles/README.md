# Dotfiles

Shared configuration files managed via home-manager and symlinked to `~/.dotfiles`.

## Purpose

This directory contains all user-level configuration files (dotfiles) that are:

1. **Managed by Nix**: Files are referenced in home-manager configurations
2. **Symlinked for editing**: Accessible at `~/.dotfiles` for direct editing
3. **Applied on activation**: Home-manager creates symlinks on each switch

## Directory Structure

```
dotfiles/
├── .config/                      # XDG configuration directory
│   ├── alacritty/                # Alacritty terminal config
│   ├── git/                      # Git configuration
│   │   ├── config                # Main git config
│   │   ├── darwin.gitconfig      # macOS-specific git settings
│   │   └── catppuccin.gitconfig  # Color theme
│   ├── lazygit/                  # Lazygit TUI config
│   ├── nvim-lazyvim/             # LazyVim neovim configuration
│   │   ├── init.lua              # Main entry point
│   │   ├── lua/                  # Lua modules (options, keymaps, plugins)
│   │   └── .editorconfig         # Editor settings
│   ├── opencode/                 # Custom application configs
│   ├── vim/                      # Vim configuration
│   │   └── vimrc                 # Vim config file
│   └── zed/                      # Zed editor settings
├── .local/                       # Local data directory
│   └── bin/                      # Custom shell scripts
└── .npmrc                        # NPM configuration
```

## Symlink Mechanism

The entire `dotfiles/` directory is symlinked to `~/.dotfiles`:

```bash
ln -s "$(pwd)/dotfiles" ~/.dotfiles
```

This allows you to:

- **Edit files directly**: `vim ~/.dotfiles/.config/git/config`
- **Track changes easily**: All changes are in this directory
- **Avoid rebuilding**: Edit files here, then `home-manager switch` to apply

## How Files Are Managed

### XDG Config Files (`xdg.configFile`)

Configuration files in `~/.config/` are managed via `xdg.configFile`:

```nix
# In home-manager configuration
xdg.configFile = {
  "git/config".source = symlink ".config/git/config";
  "lazygit/config.yml".source = symlink ".config/lazygit/config.yml";
};
```

This creates:
- Symlink from `~/.config/git/config` → `~/.dotfiles/.config/git/config`
- Symlink from `~/.config/lazygit/config.yml` → `~/.dotfiles/.config/lazygit/config.yml`

### Home Files (`home.file`)

Files in home directory (`~/.xxx`) are managed via `home.file`:

```nix
home.file.".local/bin/script" = {
  source = "${inputs.self}/dotfiles/.local/bin/script";
  executable = true;
};
```

This creates:
- Symlink from `~/.local/bin/script` → `/nix/store/...-script`

## Managing Dotfiles

### Adding New Configuration

1. Place file in `dotfiles/` following XDG structure:

```bash
# For a new app called "myapp"
mkdir -p dotfiles/.config/myapp
vim dotfiles/.config/myapp/config.yaml
```

2. Add to host configuration:

```nix
# In hosts/<host>/home.nix or a feature module
{
  xdg.configFile."myapp/config.yaml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/.config/myapp/config.yaml";
}
```

3. Apply changes:

```bash
home-manager switch --flake .#<user>@<host>
```

### Editing Existing Configs

Simply edit the file in `~/.dotfiles/`:

```bash
# Edit git config
vim ~/.dotfiles/.config/git/config

# Edit neovim config
vim ~/.dotfiles/.config/nvim-lazyvim/lua/config/options.lua
```

Then apply changes:

```bash
home-manager switch --flake .#<user>@<host>
```

### Removing a Dotfile

1. Remove file from `dotfiles/`:
```bash
rm ~/.dotfiles/.config/old-app/config
```

2. Remove from home-manager configuration:
```nix
# Remove the xdg.configFile or home.file entry
```

3. Apply changes:
```bash
home-manager switch --flake .#<user>@<host>
```

## Managed Configurations

### Editor Configurations

#### Neovim (LazyVim)
- **Location**: `.config/nvim-lazyvim/`
- **Structure**: Modular Lua configuration
  - `init.lua`: Entry point
  - `lua/config/`: Options, keymaps, autocmds
  - `lua/plugins/`: Plugin configurations
- **Features**: Lazy plugin management, custom keybindings, LSP setup

#### Vim
- **Location**: `.config/vim/vimrc`
- **Purpose**: Fallback editor for systems without neovim

#### Zed
- **Location**: `.config/zed/settings.json`
- **Purpose**: Modern editor configuration

### Terminal Configurations

#### Alacritty
- **Location**: `.config/alacritty/alacritty.toml`
- **Purpose**: GPU-accelerated terminal emulator settings

### Version Control

#### Git
- **Location**: `.config/git/`
- **Files**:
  - `config`: Main git configuration
  - `darwin.gitconfig`: macOS-specific settings (credential helper)
  - `catppuccin.gitconfig`: Color theme
- **Tools**:
  - [git-lfs](https://git-lfs.github.com/): Large file storage
  - [git-crypt](https://github.com/AGWA/git-crypt): Encrypted files
  - [delta](https://github.com/dandavison/delta): Better diffs
  - [lazygit](https://github.com/jesseduffield/lazygit): Terminal UI

#### Lazygit
- **Location**: `.config/lazygit/config.yml`
- **Purpose**: Terminal UI for git operations

### Development Tools

#### NPM
- **Location**: `.npmrc`
- **Purpose**: Node.js package manager configuration

## Notes

- **Out of Store Symlinks**: Many configs use `mkOutOfStoreSymlink` to allow direct editing
- **Host-Specific**: Some configs have platform-specific variants (e.g., `darwin.gitconfig`)
- **EditorConfig**: `.editorconfig` files enforce consistent settings across editors

## Related Documentation

- [Home Manager XDG Base Directories](https://nix-community.github.io/home-manager/options.html#opt-xdg.configfile)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
