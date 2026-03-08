# Dotfiles

Tracked application configs that are referenced by home-manager modules and usually exposed at `~/.dotfiles` for direct editing.

## What Lives Here

- `dotfiles/.config/` - XDG-style app configs such as git, lazygit, terminals, editors, and opencode.
- `dotfiles/.local/` - local scripts or data exposed through home-manager.
- top-level files like `.npmrc` when an app expects them outside `.config/`.

## How This Repo Uses Them

- Many feature modules use `config.lib.file.mkOutOfStoreSymlink` so edits in `~/.dotfiles` take effect on the next home-manager activation.
- Some files are sourced directly from the repo with `xdg.configFile` or `home.file`.
- The owning feature module is the source of truth for where a dotfile is mounted.

Representative paths:

- `dotfiles/.config/git/`
- `dotfiles/.config/lazygit/`
- `dotfiles/.config/nvim-lazyvim/`
- `dotfiles/.config/opencode/`
- `dotfiles/.config/zed/`

## Common Workflow

1. Add or edit the file under `dotfiles/`.
2. Wire or update the corresponding `xdg.configFile` / `home.file` entry in a feature module or host `home.nix`.
3. Run the relevant home-manager or system activation command.

Example:

```nix
xdg.configFile."git/config".source =
  config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/.dotfiles/.config/git/config";
```

## Keep in Mind

- Do not rename or move dotfiles without updating the feature module that references them.
- Treat secret-like material carefully; some files in this tree are not ordinary public config.
- Platform-specific variants belong next to the app config when that pattern already exists, such as `dotfiles/.config/git/darwin.gitconfig`.

## Related Docs

- `README.md` - repo entry point
- `AGENTS.md` - repo-wide rules
- `home-manager/features/AGENTS.md` - feature-module guidance
