// https://github.com/code-yeongyu/oh-my-opencode/blob/dev/docs/configurations.md#tmux-integration

## Tmux Integration

Run background subagents in separate tmux panes for **visual multi-agent execution**. See your agents working in parallel, each in their own terminal pane.

**Enable tmux integration** via `tmux` in `oh-my-opencode.json`:

```json
{
  "tmux": {
    "enabled": true,
    "layout": "main-vertical",
    "main_pane_size": 60,
    "main_pane_min_width": 120,
    "agent_pane_min_width": 40
  }
}
```

| Option | Default | Description |
|--------|---------|-------------|
| `enabled` | `false` | Enable tmux subagent pane spawning. Only works when running inside an existing tmux session. |
| `layout` | `main-vertical` | Tmux layout for agent panes. See [Layout Options](#layout-options) below. |
| `main_pane_size` | `60` | Main pane size as percentage (20-80). |
| `main_pane_min_width` | `120` | Minimum width for main pane in columns. |
| `agent_pane_min_width` | `40` | Minimum width for each agent pane in columns. |

### Layout Options

| Layout | Description |
|--------|-------------|
| `main-vertical` | Main pane left, agent panes stacked on right (default) |
| `main-horizontal` | Main pane top, agent panes stacked bottom |
| `tiled` | All panes in equal-sized grid |
| `even-horizontal` | All panes in horizontal row |
| `even-vertical` | All panes in vertical stack |

### Requirements

1. **Must run inside tmux**: The feature only activates when OpenCode is already running inside a tmux session
2. **Tmux installed**: Requires tmux to be available in PATH
3. **Server mode**: OpenCode must run with `--port` flag to enable subagent pane spawning

### How It Works

When `tmux.enabled` is `true` and you're inside a tmux session:
- Background agents (via `delegate_task(run_in_background=true)`) spawn in new tmux panes
- Each pane shows the subagent's real-time output
- Panes are automatically closed when the subagent completes
- Layout is automatically adjusted based on your configuration

### Running OpenCode with Tmux Subagent Support

To enable tmux subagent panes, OpenCode must run in **server mode** with the `--port` flag. This starts an HTTP server that subagent panes connect to via `opencode attach`.

**Basic setup**:
```bash
# Start tmux session
tmux new -s dev

# Run OpenCode with server mode (port 4096)
opencode --port 4096

# Now background agents will appear in separate panes
```

**Recommended: Shell Function**

For convenience, create a shell function that automatically handles tmux sessions and port allocation. Here's an example for Fish shell:

```fish
# ~/.config/fish/config.fish
function oc
    set base_name (basename (pwd))
    set path_hash (echo (pwd) | md5 | cut -c1-4)
    set session_name "$base_name-$path_hash"

    # Find available port starting from 4096
    function __oc_find_port
        set port 4096
        while test $port -lt 5096
            if not lsof -i :$port >/dev/null 2>&1
                echo $port
                return 0
            end
            set port (math $port + 1)
        end
        echo 4096
    end

    set oc_port (__oc_find_port)
    set -x OPENCODE_PORT $oc_port

    if set -q TMUX
        # Already inside tmux - just run with port
        opencode --port $oc_port $argv
    else
        # Create tmux session and run opencode
        set oc_cmd "OPENCODE_PORT=$oc_port opencode --port $oc_port $argv; exec fish"
        if tmux has-session -t "$session_name" 2>/dev/null
            tmux new-window -t "$session_name" -c (pwd) "$oc_cmd"
            tmux attach-session -t "$session_name"
        else
            tmux new-session -s "$session_name" -c (pwd) "$oc_cmd"
        end
    end

    functions -e __oc_find_port
end
```

**Bash/Zsh equivalent**:

```bash
# ~/.bashrc or ~/.zshrc
oc() {
    local base_name=$(basename "$PWD")
    local path_hash=$(echo "$PWD" | md5sum | cut -c1-4)
    local session_name="${base_name}-${path_hash}"

    # Find available port
    local port=4096
    while [ $port -lt 5096 ]; do
        if ! lsof -i :$port >/dev/null 2>&1; then
            break
        fi
        port=$((port + 1))
    done

    export OPENCODE_PORT=$port

    if [ -n "$TMUX" ]; then
        opencode --port $port "$@"
    else
        local oc_cmd="OPENCODE_PORT=$port opencode --port $port $*; exec $SHELL"
        if tmux has-session -t "$session_name" 2>/dev/null; then
            tmux new-window -t "$session_name" -c "$PWD" "$oc_cmd"
            tmux attach-session -t "$session_name"
        else
            tmux new-session -s "$session_name" -c "$PWD" "$oc_cmd"
        fi
    fi
}
```

**How subagent panes work**:

1. Main OpenCode starts HTTP server on specified port (e.g., `http://localhost:4096`)
2. When a background agent spawns, Oh My OpenCode creates a new tmux pane
3. The pane runs: `opencode attach http://localhost:4096 --session <session-id>`
4. Each subagent pane shows real-time streaming output
5. Panes are automatically closed when the subagent completes

**Environment variables**:

| Variable | Description |
|----------|-------------|
| `OPENCODE_PORT` | Default port for the HTTP server (used if `--port` not specified) |

### Server Mode Reference

OpenCode's server mode exposes an HTTP API for programmatic interaction:

```bash
# Standalone server (no TUI)
opencode serve --port 4096

# TUI with server (recommended for tmux integration)
opencode --port 4096
```

| Flag | Default | Description |
|------|---------|-------------|
| `--port` | `4096` | Port for HTTP server |
| `--hostname` | `127.0.0.1` | Hostname to listen on |

For more details, see the [OpenCode Server documentation](https://opencode.ai/docs/server/).
