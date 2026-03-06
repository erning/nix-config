# Homebrew Migration Analysis

将 home-manager features 按「开发工具」与「系统基础设施」分类。

- **开发工具** → 迁移到 homebrew（版本更新频繁，按项目需要安装）
- **系统基础设施** → 保留在 nix（装好系统就该有，很少变动）

---

## Homebrew: 开发工具 (17 个)

### 语言运行时 & 工具链 (9)

| Feature | 包 | 迁移难度 | 备注 |
|---|---|---|---|
| `python.nix` | python3, uv | 简单 | packages-only |
| `nodejs.nix` | nodejs_24, pnpm, bun | 简单 | 需保留 .npmrc symlink 配置 |
| `go.nix` | go | 简单 | 需保留 GOPATH 配置 |
| `rustup.nix` | rustup | 简单 | packages-only |
| `zig.nix` | zig | 简单 | packages-only |
| `jdk.nix` | jdk | 简单 | packages-only |
| `kotlin.nix` | kotlin | 简单 | packages-only |
| `gradle.nix` | gradle | 简单 | packages-only |
| `typst.nix` | typst (+条件字体) | 简单 | packages-only |

### 构建工具 (1)

| Feature | 包 | 迁移难度 | 备注 |
|---|---|---|---|
| `build-essential.nix` | bison, flex, gcc, gnumake, pkg-config, autoconf, automake, libtool, libiconv, fontforge, makeWrapper | 中等 | macOS 部分由 Xcode CLI Tools 提供；makeWrapper 是 nix 特有的 |

### 版本控制 (1)

| Feature | 包 | 迁移难度 | 备注 |
|---|---|---|---|
| `git.nix` | git, git-lfs, git-crypt, delta, lazygit | 简单 | 需保留 xdg.configFile 配置（git config, lazygit config, darwin.gitconfig） |

### 编辑器 (2)

| Feature | 包 | 迁移难度 | 备注 |
|---|---|---|---|
| `neovim.nix` | neovim | 中等 | 需保留 LazyVim 配置、lazyvim wrapper 脚本、EDITOR/VISUAL 环境变量、vi alias |
| `vim.nix` | vim | 中等 | 需保留 vimrc symlink；vim plugins 由 nix 管理（catppuccin, polyglot, editorconfig, lightline），迁移后需改用 vim 插件管理器 |

### 开发辅助 (4)

| Feature | 包 | 迁移难度 | 备注 |
|---|---|---|---|
| `direnv.nix` | direnv | 简单 | packages-only |
| `just.nix` | just | 简单 | packages-only |
| `docker.nix` | lazydocker | 简单 | packages-only |
| `nix-support.nix` | nil, nixd, nixfmt | 低优先级 | Nix 生态工具，homebrew 未必有；且继续用 nix 管理反而更合理 |

### Homebrew Brewfile 参考

```ruby
# 语言 & 工具链
brew "python"
brew "uv"
brew "node"
brew "pnpm"
brew "bun"
brew "go"
brew "rustup"
brew "zig"
brew "openjdk"
brew "kotlin"
brew "gradle"
brew "typst"

# 版本控制
brew "git"
brew "git-lfs"
brew "git-crypt"
brew "delta"
brew "lazygit"

# 编辑器
brew "neovim"
brew "vim"

# 开发辅助
brew "direnv"
brew "just"
brew "lazydocker"

# 构建 (部分 Xcode CLI Tools 已提供)
brew "bison"
brew "flex"
brew "gcc"
brew "make"
brew "pkg-config"
brew "autoconf"
brew "automake"
brew "libtool"
```

---

## Nix: 系统基础设施 (18 个)

### Shell 环境 (4)

| Feature | 类型 | 说明 |
|---|---|---|
| `fish.nix` | programs.fish.enable | 主 shell，装系统时就该有 |
| `bash.nix` | programs.bash.enable | 基础 shell |
| `zsh.nix` | programs.zsh.enable | 基础 shell + dotDir 配置 |
| `nushell.nix` | programs.nushell.enable | 备选 shell |

### Shell 增强 (5)

| Feature | 类型 | 说明 |
|---|---|---|
| `starship.nix` | programs.starship + config symlink | shell prompt，用 unstable 包 |
| `eza.nix` | programs.eza (git, icons) | ls 替代，shell 基础工具 |
| `fzf.nix` | programs.fzf + shell integrations | 模糊搜索，shell 基础工具 |
| `bat.nix` | programs.bat + themes | cat 替代，shell 基础工具 |
| `zoxide.nix` | programs.zoxide + shell integrations | cd 替代，shell 基础工具 |

### 终端复用 & 文件管理 (3)

| Feature | 类型 | 说明 |
|---|---|---|
| `tmux.nix` | programs.tmux + 完整配置 | 终端复用器，配置复杂（prefix, vi-mode, catppuccin 主题） |
| `zellij.nix` | home.packages + config symlink | 终端复用器 |
| `yazi.nix` | programs.yazi + shell integrations + themes | 文件管理器 |

### SSH (1)

| Feature | 类型 | 说明 |
|---|---|---|
| `ssh.nix` | programs.ssh + home.file | 系统基础，matchBlocks、authorized_keys、conf.d |

### 字体 (1)

| Feature | 类型 | 说明 |
|---|---|---|
| `fonts.nix` | home.packages + fontconfig | 系统字体，装好就不动 |

### 终端 & 编辑器配置 (4)

| Feature | 类型 | 说明 |
|---|---|---|
| `ghostty.nix` | xdg.configFile symlink | 纯配置，不装包 |
| `kitty.nix` | xdg.configFile symlinks | 纯配置，不装包 |
| `alacritty.nix` | xdg.configFile symlink | 纯配置，不装包 |
| `zed.nix` | xdg.configFile symlink | 纯配置，不装包 |

---

## 迁移后 nix 模块需要的改动

### 1. Packages-only 模块 → 删除或清空

以下模块迁移后可以直接删除，因为没有任何配置需要保留：

```
zig.nix, direnv.nix, python.nix, just.nix, docker.nix,
rustup.nix, jdk.nix, kotlin.nix, gradle.nix, typst.nix,
build-essential.nix
```

### 2. Both 模块 → 保留配置，移除 home.packages

以下模块需要改为 config-only，删掉 `home.packages` 部分：

| 模块 | 保留的配置 |
|---|---|
| `git.nix` | xdg.configFile (git config, lazygit config, catppuccin theme, darwin.gitconfig) |
| `neovim.nix` | xdg.configFile (LazyVim), home.file (lazyvim wrapper), sessionVariables, shell aliases |
| `vim.nix` | home.file (.vim/vimrc symlink)；**注意**: vim plugins 目前由 nix 管理，需改用原生插件管理器 |
| `nodejs.nix` | home.file (.npmrc symlink) |
| `go.nix` | programs.go (GOPATH) |

### 3. nix-support.nix → 建议保留在 nix

nil, nixd, nixfmt 是 Nix 生态工具，homebrew 不一定有且版本可能落后。留在 nix 管理更合理。

### 4. 系统基础设施中 programs.X.enable 模块 → 无需改动

这些模块的包由 home-manager 的 programs 模块隐式管理，不需要迁移。如果确实想从 homebrew 装这些包，需要设置 `programs.X.package = null` 来阻止 nix 安装，但一般没有必要。
