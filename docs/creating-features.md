# 创建 Feature 模块

本项目的 feature 模块采用 **auto-wrap** 机制（`lib/mkFeatureImports.nix`）。只需在 `home-manager/features/` 下新建 `.nix` 文件，写纯配置即可——启用开关和条件守卫由框架自动生成。

---

## 快速开始

在 `home-manager/features/` 下创建文件，例如 `ripgrep.nix`：

```nix
{ pkgs, ... }:
{
  _description = "ripgrep search tool";
  home.packages = with pkgs; [
    ripgrep
  ];
}
```

完成。无需其他操作：

- 框架自动生成 `options.features.ripgrep.enable = lib.mkEnableOption "ripgrep search tool";`（描述来自 `_description`）
- 配置体自动包裹在 `lib.mkIf config.features.ripgrep.enable { ... }` 中
- feature 名称从文件名派生（`ripgrep.nix` → `"ripgrep"`）

然后在 host 的 `home.nix` 中启用：

```nix
features.ripgrep.enable = true;
```

或添加到 `home-manager/presets.nix` 的某个 preset 中：

```nix
devtools = {
  ripgrep.enable = lib.mkDefault true;
  # ...
};
```

---

## 常见模式

### 仅安装包

```nix
# direnv.nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    direnv
  ];
}
```

### 启用 programs 模块

```nix
# fzf.nix
{ ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };
}
```

### 符号链接 dotfiles

使用 `config.lib.dotfiles` 辅助函数（详见 `docs/dotfiles-management.md`）：

```nix
# ghostty.nix — 链接 .config 下的文件
{ config, ... }:
{
  xdg.configFile = config.lib.dotfiles.configFiles [
    "ghostty/config"
  ];
}

# nodejs.nix — 链接 home 目录下的文件
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ nodejs_24 pnpm bun ];
  home.file = config.lib.dotfiles.homeFiles [
    ".npmrc"
  ];
}
```

对应的 dotfile 需放在 `dotfiles/.config/ghostty/config` 或 `dotfiles/.npmrc`。

### 使用 unstable 包

```nix
# fonts.nix
{ pkgs, ... }:
{
  home.packages = with pkgs.unstable; [
    libertine
    nerd-fonts.jetbrains-mono
  ];
}
```

### 使用 inputs（如引用仓库内文件）

```nix
# bat.nix
{ config, inputs, ... }:
{
  programs.bat.enable = true;
  xdg.configFile = config.lib.dotfiles.configFiles [
    "bat/config"
  ] // {
    "bat/themes" = {
      source = "${inputs.self}/dotfiles/.config/bat/themes";
      recursive = true;
    };
  };
}
```

### 使用 settings（平台判断）

```nix
# ssh.nix
{ config, settings, ... }:
{
  _description = "SSH client";
  programs.ssh = {
    enable = true;
    includes = [
      "conf.d/*.conf"
    ]
    ++ (if settings.isDarwin then [ "~/.orbstack/ssh/config" ] else [ ]);
  };

  home.file = config.lib.dotfiles.homeFiles [
    ".ssh/authorized_keys"
    ".ssh/conf.d/homelab.conf"
  ];
}
```

### 使用 let 绑定

```nix
# vim.nix
{ config, pkgs, ... }:
let
  start = ".vim/pack/vendor/start";
  plugins = pkgs.vimPlugins;
in
{
  home.packages = with pkgs; [ vim ];
  home.file = {
    "${start}/catppuccin-vim".source = "${plugins.catppuccin-vim}";
    "${start}/vim-polyglot".source = "${plugins.vim-polyglot}";
  };
}
```

### 版本守卫（兼容旧版 home-manager）

当某些选项不存在于所有 home-manager 版本时，使用 `lib.optionalAttrs`：

```nix
# go.nix
{ pkgs, lib, options, ... }:
({
  home.packages = with pkgs; [ go ];
  programs.go.enable = true;
} // lib.optionalAttrs (options.programs.go ? env) {
  programs.go.env = { GOPATH = ".go"; };
})
```

**注意**：必须用 `lib.optionalAttrs`（属性级守卫），不能用 `lib.mkIf`（值级守卫）。后者仍会暴露属性路径给模块系统，导致旧版报错。

---

## 嵌套 Feature

在子目录中创建文件即可生成嵌套 feature：

```
home-manager/features/
  fonts.nix             → features.fonts
  fonts/source-han.nix  → features.fonts.source-han
```

子目录中的 `default.nix` 会被跳过（不再需要）。

在 preset 中启用嵌套 feature：

```nix
graphical = {
  fonts.enable = lib.mkDefault true;
  fonts.source-han.enable = lib.mkDefault true;
};
```

---

## 描述（`_description`）

每个 feature 都应包含 `_description` 作为返回 attrset 的第一个属性，用作 `mkEnableOption` 的描述文本。若未提供，默认值为文件名派生的 feature 名。当前所有 feature 均已包含此属性：

```nix
# nix-support.nix — 名称 "nix-support"，但描述为 "nix support"
{ pkgs, ... }:
{
  _description = "nix support";
  home.packages = with pkgs; [ nil nixd nixfmt ];
}

# fonts/source-han.nix — 名称 "fonts.source-han"，但描述为 "fonts - Source Han"
{ pkgs, ... }:
{
  _description = "fonts - Source Han";
  home.packages = with pkgs.unstable; [ source-han-sans source-han-serif source-han-mono ];
}
```

`_description` 会在包裹前被移除，不会出现在最终配置中。

---

## 可用的函数参数

feature 模块函数可以使用以下参数（框架会透传所有模块参数）：

| 参数 | 来源 | 说明 |
|------|------|------|
| `config` | 模块系统 | 最终合并后的配置 |
| `lib` | 模块系统 | nixpkgs 库函数 |
| `pkgs` | `_module.args` | 当前 nixpkgs 包集（含 `pkgs.unstable`、`pkgs.stable` overlay） |
| `options` | 模块系统 | 所有已声明的选项（用于版本守卫） |
| `settings` | `extraSpecialArgs` | `{ user, host, system, isDarwin, isLinux, nixpkgsSeries }` |
| `inputs` | `extraSpecialArgs` | 所有 flake inputs |

只需在函数参数中声明需要的即可，必须包含 `...`：

```nix
{ config, pkgs, ... }:  # OK
{ pkgs, ... }:          # OK — 最简形式
{ ... }:                # OK — 不需要任何参数时
```

---

## 检查清单

1. 在 `home-manager/features/` 下创建 `.nix` 文件（或子目录中的 `.nix` 文件）
2. 编写纯配置函数，**不要**写 `options`、`mkEnableOption`、`mkIf` 等 boilerplate
3. 如需引用 dotfiles，先在 `dotfiles/` 对应路径下创建文件
4. 添加 `_description = "...";` 作为返回 attrset 的第一个属性
5. 在 host `home.nix` 或 `home-manager/presets.nix` preset 中启用
6. 验证：至少在一个 default-series host 和一个 25.05-series host 上构建
   ```bash
   # default/unstable channel
   home-manager build --flake .#erning@dragon
   # 25.05 channel
   home-manager build --flake .#erning@pterosaur
   ```
