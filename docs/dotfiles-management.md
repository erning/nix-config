# Dotfiles 管理方式详解

本项目通过 home-manager feature 模块管理 dotfiles，使用三种链接策略将 `dotfiles/` 下的配置文件映射到用户 home 目录。

---

## 方法一：`mkOutOfStoreSymlink` — 可编辑符号链接

### 原理

通过 `config.lib.file.mkOutOfStoreSymlink` 创建一个指向 `~/.dotfiles/` 的符号链接，**绕过 Nix store**。文件不会被复制到 `/nix/store/`，而是直接链接到仓库克隆路径。

```
~/.config/git/config → ~/.dotfiles/.config/git/config → (仓库实际文件)
```

### 优点

- **即时编辑**：修改 `~/.dotfiles/` 下的文件后立即生效（下次应用读取时），无需 rebuild
- **开发友好**：可以用任何编辑器直接改配置，快速迭代
- **git 可追踪**：改动直接反映在 git diff 中，方便 review 和 commit
- **适合频繁调整的配置**：如 git config、shell prompt、terminal 设置等

### 缺点

- **依赖固定路径**：假设仓库始终在 `~/.dotfiles/`，如果仓库位置变更，所有链接失效
- **不可重现**：符号链接指向 store 外部，Nix 无法保证内容一致性；不同机器上同一 flake 构建结果可能不同（取决于本地 `~/.dotfiles/` 内容）
- **权限敏感**：文件权限由文件系统决定，不受 Nix 管理
- **激活时才生效**：链接本身仍需 `home-manager switch` 创建，只是链接创建后文件内容的修改不需要 rebuild

### 适用场景

- 需要频繁手动编辑的配置文件（git config、lazygit、starship、terminal 配置等）
- SSH 配置（authorized_keys、conf.d/*.conf）
- 编辑器配置文件（zed、alacritty、ghostty 等）

### 代码模式

使用 `config.lib.dotfiles` 集中 helper（定义在 `home-manager/home.nix`）：

```nix
{
  # XDG config 目录下的文件（批量）
  xdg.configFile = config.lib.dotfiles.configFiles [
    "app/config.toml"
  ];

  # 非 XDG 路径的文件（批量）
  home.file = config.lib.dotfiles.homeFiles [
    ".ssh/conf.d/myhost.conf"
    ".npmrc"
  ];

  # 路径不匹配时使用低级 symlink
  home.file.".vim/vimrc".source = config.lib.dotfiles.symlink ".config/vim/vimrc";
}
```

### 实际示例

| Feature 模块 | 链接的文件 | Helper |
|---|---|---|
| `git.nix` | `git/config`, `git/config.local`, `git/catppuccin.gitconfig`, `lazygit/config.yml` | `configFiles` |
| `git.nix` | `.gitignore_global` | `homeFiles` |
| `kitty.nix` | `kitty/kitty.conf`, `kitty/kitty.app.png`, `kitty/current-theme.conf` | `configFiles` |
| `starship.nix` | `starship.toml` | `configFiles` |
| `ssh.nix` | `.ssh/authorized_keys`, `.ssh/conf.d/homelab.conf`, `.ssh/conf.d/vps.conf` | `homeFiles` |
| `bat.nix` | `bat/config` | `configFiles` |
| `yazi.nix` | `yazi/theme.toml` | `configFiles` |
| `ghostty.nix` | `ghostty/config` | `configFiles` |
| `alacritty.nix` | `alacritty/alacritty.toml` | `configFiles` |
| `zed.nix` | `zed/settings.json` | `configFiles` |
| `zellij.nix` | `zellij/config.kdl` | `configFiles` |
| `nodejs.nix` | `.npmrc` | `homeFiles` |
| `vim.nix` | `.config/vim/vimrc` | `symlink` |
| `claude-code.nix` | `cce/kimi.env`, `cce/minimax.env`, `cce/zhipu.env` | `configFiles` |
| `opencode.nix` | `opencode/opencode.json` | `configFiles` |

---

## 方法二：`inputs.self` 直接引用 — 只读 Store 路径

### 原理

直接使用 `"${inputs.self}/dotfiles/..."` 引用仓库中的文件。Nix 会将文件复制到 `/nix/store/`，然后从 store 路径创建链接。

```
~/.config/nvim-lazyvim/ → /nix/store/xxxx-source/dotfiles/.config/nvim-lazyvim/
```

### 优点

- **完全可重现**：文件内容被 Nix store 哈希锁定，任何机器上同一 flake 构建的结果完全一致
- **支持 `recursive = true`**：可以一次性链接整个目录树，适合复杂的嵌套配置结构
- **不依赖仓库位置**：文件在 store 中，不需要 `~/.dotfiles/` 存在于特定路径
- **不可变性**：用户不会意外修改配置，保证系统状态一致

### 缺点

- **每次修改必须 rebuild**：改了 dotfile 后必须 `home-manager switch` 才能生效
- **迭代慢**：调试配置时需要反复 rebuild，周期长
- **store 占用**：每次变更都会在 `/nix/store/` 产生新路径（旧版本会被 GC）
- **只读**：运行时无法直接编辑 `~/.config/` 下的文件（它指向 store，store 是只读的）

### 适用场景

- 主题文件、色彩方案等不需要手动编辑的静态资源
- 需要跨机器完全一致的只读配置
- 生成的或机器维护的配置（不需要人工干预）
- 二进制文件、图片等非文本资源

### 代码模式

```nix
{
  # 单个文件
  xdg.configFile."app/theme.toml".source =
    "${inputs.self}/dotfiles/.config/app/theme.toml";

  # 递归复制整个目录
  xdg.configFile."nvim-lazyvim" = {
    source = "${inputs.self}/dotfiles/.config/nvim-lazyvim";
    recursive = true;
  };

  # 非 XDG 路径
  home.file.".local/bin/myscript" = {
    source = "${inputs.self}/dotfiles/.local/bin/myscript";
  };
}
```

### 实际示例

| Feature 模块 | 链接的文件 | 说明 |
|---|---|---|
| `bat.nix` | `bat/themes/`（整个目录） | 语法高亮主题，recursive=true |
| `yazi.nix` | `Catppuccin-mocha.tmTheme` | 色彩主题文件 |

---

## 方法三：`symlinkDir` — 递归可编辑符号链接

### 原理

通过 `lib/symlink-dir.nix` 在 eval 时递归扫描目录树（`builtins.readDir`），为每个文件生成一条 `mkOutOfStoreSymlink`。效果等同于对目录下每个文件分别使用方法一，但无需手动列举。

```
~/.config/nvim-lazyvim/init.lua        → ~/.dotfiles/.config/nvim-lazyvim/init.lua
~/.config/nvim-lazyvim/lua/config/*.lua → ~/.dotfiles/.config/nvim-lazyvim/lua/config/*.lua
```

### 优点

- **即时编辑**：与方法一相同，修改后立即生效，无需 rebuild
- **递归目录**：与方法二相同，一次性处理整个目录树
- **git 可追踪**：改动直接反映在 git diff 中

### 缺点

- **依赖固定路径**：同方法一，假设仓库在 `~/.dotfiles/`
- **不可重现**：同方法一，内容取决于本地文件
- **新增文件需 rebuild**：目录结构在 eval 时确定；新增或删除文件后需要 `home-manager switch` 重新生成链接列表

### 适用场景

- 需要递归链接且同时需要可编辑的目录（如 neovim 配置、复杂的多文件应用配置）
- 目录结构稳定但文件内容需要频繁调整的场景

### 代码模式

使用 `config.lib.dotfiles` 便捷 wrapper：

```nix
{
  # XDG config 目录
  xdg.configFile = config.lib.dotfiles.configDir "nvim-lazyvim";

  # home 目录
  home.file = config.lib.dotfiles.homeDir ".vim";
}
```

### 实际示例

| Feature 模块 | 链接的目录 | Helper |
|---|---|---|
| `neovim.nix` | `nvim-lazyvim/`（LazyVim 完整配置） | `configDir` |

### 与其他条目合并

```nix
xdg.configFile = config.lib.dotfiles.configFiles [
  "bat/config"
] // config.lib.dotfiles.configDir "bat/themes";
```

---

## 混合使用

同一个 feature 模块可以同时使用多种方法。典型模式是：**人工编辑的主配置用 symlink，静态主题/资源用 inputs.self，需要递归且可编辑的目录用 symlinkDir**。

`bat.nix` 是最好的混合示例：

```nix
{
  xdg.configFile = config.lib.dotfiles.configFiles [
    # 主配置 → 可编辑 symlink
    "bat/config"
  ] // {
    # 主题目录 → 只读 store 引用
    "bat/themes" = {
      source = "${inputs.self}/dotfiles/.config/bat/themes";
      recursive = true;
    };
  };
}
```

---

## 新建 Feature 的完整步骤

### 步骤 1：在 `dotfiles/` 下放置配置文件

```
dotfiles/.config/myapp/config.toml    # 主配置（需要手动编辑）
dotfiles/.config/myapp/themes/        # 主题目录（静态资源）
```

### 步骤 2：创建 feature 模块

在 `home-manager/features/myapp.nix` 创建文件（会被 `mkFeatureImports.nix` 自动发现并包裹，无需手动注册或编写 boilerplate）：

```nix
{ config, pkgs, inputs, ... }:
{
  _description = "myapp configuration";

  # 安装包
  home.packages = with pkgs; [
    myapp
  ];

  xdg.configFile = config.lib.dotfiles.configFiles [
    # 方法一：可编辑 symlink（频繁编辑的配置）
    "myapp/config.toml"
  ] // {
    # 方法二：只读 store 引用（主题、静态资源）
    "myapp/themes" = {
      source = "${inputs.self}/dotfiles/.config/myapp/themes";
      recursive = true;
    };
  };
}
```

**注意**：不要手写 `options.features.*.enable`、`lib.mkEnableOption`、`lib.mkIf` 等 boilerplate。框架（`mkFeatureImports.nix`）会自动生成这些。详见 `docs/creating-features.md`。

### 步骤 3：在 host 的 `home.nix` 中启用

```nix
features.myapp.enable = true;
```

或者将其加入 `home-manager/presets.nix` 的某个 preset bundle 中。

### 步骤 4：验证

```bash
nix flake check
darwin-rebuild build --flake .#<host>       # macOS
nixos-rebuild dry-build --flake .#<host>    # NixOS
```

---

## 决策指南：选哪种方法？

| 判断条件 | 方法一 (symlink) | 方法二 (inputs.self) | 方法三 (symlinkDir) |
|---|---|---|---|
| 需要手动编辑？ | **是** | 否 | **是** |
| 需要递归复制目录？ | 否 | **是** | **是** |
| 是主题/色彩方案？ | 否 | **是** | 否 |
| 需要跨机器完全一致？ | 否 | **是** | 否 |
| 是否为文本配置文件？ | **是** | 都可以 | **是** |
| 是否为二进制/图片？ | 不推荐 | **是** | 不推荐 |
| 需要频繁迭代调试？ | **是** | 否 | **是** |

**经验法则：如果你会用编辑器打开它，用 symlink；如果你不会手动改它，用 inputs.self。需要递归且可编辑？用 symlinkDir。**

---

## 挂载点对照

| 目标位置 | 使用的 API | 示例 |
|---|---|---|
| `~/.config/xxx` | `xdg.configFile."xxx"` | `xdg.configFile."git/config"` |
| `~/.xxx`（home 根目录） | `home.file.".xxx"` | `home.file.".npmrc"` |
| `~/.ssh/xxx` | `home.file.".ssh/xxx"` | `home.file.".ssh/authorized_keys"` |
| `~/.local/bin/xxx` | `home.file.".local/bin/xxx"` | `home.file.".local/bin/myscript"` |

---

## 关键文件

- `home-manager/home.nix` — `config.lib.dotfiles` helper 定义
- `home-manager/features/default.nix` — 自动导入入口
- `lib/mkFeatureImports.nix` — feature 自动包裹引擎（enable option + mkIf）
- `lib/symlink-dir.nix` — 递归 out-of-store symlink 生成（含 yadm 风格 alternate 支持）
- `home-manager/presets.nix` — preset bundles
- `dotfiles/README.md` — dotfiles 目录说明
