## OpenCode tmux note

Local reference for this repo's tmux-based OpenCode workflow.

## What is enabled here

- `dotfiles/.config/opencode/oh-my-opencode.json` enables tmux integration.
- `dotfiles/.config/fish/functions/omo.fish` is the local Fish wrapper used to launch OpenCode with a tmux session and an available port.
- the wrapper sets `OPENCODE_PORT`, creates or reuses a session name derived from the current directory, and runs `opencode --port <port>`.

## Requirements

- run inside tmux, or let `omo` create and attach a tmux session for you
- have `tmux` and `lsof` available
- use server mode via `opencode --port ...` so background panes can attach

## Typical workflow

```fish
omo
```

or, if already inside tmux:

```fish
omo <args>
```

Background agents will open in tmux panes according to the layout defined in `oh-my-opencode.json`.

## Upstream Reference

For the full upstream option matrix and generic shell examples, see:
<https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/configurations.md#tmux-integration>
