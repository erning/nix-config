# nix-config 全面审查：改进建议

**日期**：2026-03-12
**Commit**：`572400a`（master）

对整个 nix-config 仓库进行全面代码审查，目标是找出可以让配置更简洁、更优雅、更易维护的改进点。以下按影响程度分类列出。

---

## 一、高影响：减少重复样板代码

### 1. 每个 host home.nix 都重复导入 presets（8处）

**现状**：所有 8 个 host 的 `home.nix` 都有一行完全相同的代码：
```nix
presets = import "${inputs.self}/home-manager/presets.nix" { inherit lib; };
```

**建议**：在 `home-manager/home.nix` 或 `lib/mkHome.nix` 中统一导入 presets，通过 `specialArgs` 或 `config.lib` 暴露给所有 host，使 host home.nix 直接使用 `presets.workstation` 而不需要每次 import。

**涉及文件**：`lib/mkHome.nix`、`home-manager/home.nix`、所有 `hosts/*/home.nix`

---

### 2. SSH key 导入样板重复（6处）+ vmfusion 不一致

**现状**：6 个 host 用完全相同的模式导入 `ssh-key.nix`：
```nix
ssh-key = (import "${inputs.self}/lib/ssh-key.nix" { inherit config inputs; }) settings.host;
imports = [ (ssh-key "id_ed25519") ];
```
而 `vmfusion` 手动展开了相同逻辑（用 `age.secrets` 直接配置），`orbstack` 则完全没有 SSH key。

**建议**：
- 将 SSH key 配置提升为一个 feature 模块（如 `features/ssh-keys.nix`），通过 option 声明需要的 key 列表，默认导入 `id_ed25519`
- 或者在 `home-manager/secrets.nix` 中根据 `settings.host` 自动发现可用的 key
- vmfusion 应统一使用 `ssh-key.nix` helper，只需传 `"vm"` 作为 host 参数即可

**涉及文件**：`lib/ssh-key.nix`、所有 `hosts/*/home.nix`

---

### 3. `user = "erning"` 在 flake.nix 重复 8 次

**现状**：每个 `mkHome` 调用都传 `user = "erning"`，但实际只有一个用户。

**建议**：给 `mkHome` 添加默认 `user` 参数：
```nix
mkHome = import ./lib/mkHome.nix { inherit nixpkgs home-manager inputs; user = "erning"; };
```
调用时只需 `mkHome { host = "dragon"; system = "aarch64-darwin"; }`，需要时仍可覆盖。

**涉及文件**：`lib/mkHome.nix`、`flake.nix`

---

### 4. flake.nix 主机定义可以数据驱动

**现状**：每个 host 需要 5-8 行几乎相同的声明（mkSystem + mkHome），8 个 host 约 110 行。

**建议**：用 host 列表 + map 生成：
```nix
hosts = [
  { name = "dragon"; system = "aarch64-darwin"; type = "darwin"; }
  { name = "dinosaur"; system = "x86_64-darwin"; type = "darwin"; }
  { name = "phoenix"; system = "x86_64-linux"; type = "nixos"; }
  { name = "pomelo"; system = "x86_64-linux"; type = "home-only"; }
  # pinned hosts
  { name = "pterosaur"; system = "x86_64-darwin"; type = "darwin";
    builder = mkSystem-2505; homeBuilder = mkHome-2505; }
  ...
];
```
好处：添加新主机只需加一行，格式天然一致。注释可以保留在列表项旁。

**涉及文件**：`flake.nix`

---

## 二、中等影响：一致性和优雅度

### 5. 平台检测 `isDarwin` 模式重复 4 处

**现状**：`builtins.match ".*-darwin" settings.system != null` 出现在：
- `lib/mkSystem.nix:13`
- `modules/system.nix:9`
- `home-manager/home.nix:4`
- 部分 feature 模块（如 `git.nix`、`ssh.nix`）

**建议**：在 `settings` 中直接加入 `isDarwin` 和 `isLinux`：
```nix
settings = {
  inherit host system;
  isDarwin = builtins.match ".*-darwin" system != null;
  isLinux = builtins.match ".*-linux" system != null;
};
```
所有模块直接用 `settings.isDarwin`，无需各自计算。

**涉及文件**：`lib/mkSystem.nix`、`lib/mkHome.nix`、`modules/system.nix`、`home-manager/home.nix`、`home-manager/features/git.nix`、`home-manager/features/ssh.nix`

---

### 6. 数据库客户端包在 3 个 host 重复

**现状**：`dragon`、`phoenix`、`pomelo` 的 home.nix 都有：
```nix
home.packages = with pkgs; [ postgresql mariadb.client ];
```

**建议**：提取为 feature 模块 `features/database-clients.nix`，在需要的 host 启用，或加入某个 preset。

**涉及文件**：新建 `home-manager/features/database-clients.nix`，修改 3 个 host 的 `home.nix`

---

### 7. 单 preset 时 `lib.mkMerge` 多余

**现状**：5 个 host 写了 `features = lib.mkMerge [ presets.workstation ];`，只有一个元素的 `mkMerge` 等同于直接赋值。

**建议**：简化为 `features = presets.workstation;`。仅在合并多项时才用 `mkMerge`。

**涉及文件**：`hosts/{dragon,dinosaur,pomelo,orbstack,vmfusion}/home.nix`

---

### 8. NixOS host 重复 user/fish 配置

**现状**：`phoenix` 和 `vmfusion` 的 `configuration.nix` 都手写了 `programs.fish.enable = true` 和 `users.users.erning` 块，内容大同小异。

**建议**：在 `modules/nixos.nix`（或新建 `modules/users.nix`）中提供带 `mkDefault` 的共享用户配置，host 只需覆盖差异部分（如 uid、extraGroups）。

**涉及文件**：`modules/nixos.nix`、`hosts/phoenix/configuration.nix`、`hosts/vmfusion/configuration.nix`

---

### 9. legacy macOS 的 nushell disable 可提取为 preset 变体

**现状**：`pterosaur` 和 `mango` 都写了 `{ nushell.enable = false; }`，`phoenix` 也是。

**建议**：
- 方案 A：presets.nix 中加一个 `workstation-legacy` = `workstation // { nushell.enable = lib.mkDefault false; }`
- 方案 B：保持现状（3 处而已，显式清晰）

这条看个人偏好，列出供参考。

---

## 三、低影响但提升品质

### 10. Feature 模块 `_description` 缺失严重

**现状**：39 个 feature 中只有 2 个（`nix-support`、`fonts.source-han`）有 `_description`。缺少 description 时，`mkFeatureImports` 自动用文件名作为 mkEnableOption 的描述，对 `nix-options` 查询不友好。

**建议**：为所有 feature 加上 `_description`，尤其是名字不能自解释的（如 `docker.nix` 实际只装了 lazydocker）。

---

### 11. Feature 参数风格不一致

**现状**：有些 feature 用 `_:` 忽略所有参数，有些用 `{ ... }:`。

**建议**：统一用 `{ ... }:` 或 `_:`，选一种坚持。推荐 `{ ... }:` 因为更惯用，且未来添加依赖时不需改签名。

---

### 12. vim/neovim dotfile 策略不一致

**现状**：
- `neovim.nix` 直接用 `"${inputs.self}/dotfiles/.config/nvim"` + `recursive = true`
- `vim.nix` 用 `config.lib.dotfiles.symlink` 手动指定每个文件

**建议**：统一使用 `config.lib.dotfiles.configDir` 处理目录型配置，保持风格一致。

---

### 13. `typst.nix` 跨 feature 依赖未文档化

**现状**：`typst.nix` 引用了 `config.features.fonts.enable` 来决定是否添加字体路径，但没有注释说明这个跨 feature 依赖。

**建议**：加一行注释说明依赖关系。

---

### 14. shell 集成覆盖不一致

**现状**：`yazi` 和 `zoxide` 启用了 Nushell 集成，但 `neovim` 的 shell alias（`vi = nvim`）只加了 fish/bash/zsh，缺少 nushell。

**建议**：如果 nushell 是标配 shell，所有 shell alias 都应覆盖到。

---

### 15. vmfusion 的 SSH key 用 `"ssh/vm/"` 路径而非 `"ssh/vmfusion/"`

**现状**：vmfusion 手写了 `age.secrets."ssh/vm/id_ed25519"`，与其他 host 用 `settings.host`（即 `"vmfusion"`）作为路径的惯例不一致。

**建议**：如果 secrets 仓库中目录确实叫 `vm/`，可以通过在 `settings` 中加一个 `sshHost` 字段来处理，避免特殊逻辑。

---

### 16. stable 输入定义了但未使用

**现状**：`flake.nix` 定义了 `nixpkgs-stable`、`nix-darwin-stable`、`home-manager-stable` 三组输入，但 outputs 中没有任何 host 使用它们。

**建议**：如果是预留的，加注释说明；否则移除以减少 lock 文件体积和更新成本。

---

## 四、建议优先级排序

| 优先级 | 编号 | 改动 | 减少样板 |
|--------|------|------|----------|
| ★★★ | 1 | presets 统一导入 | 8 处 import 消除 |
| ★★★ | 2 | SSH key 机制统一 | 6 处样板 + 1 不一致 |
| ★★★ | 5 | settings.isDarwin | 4 处重复计算消除 |
| ★★☆ | 3 | mkHome 默认 user | 8 处 `user = "erning"` 消除 |
| ★★☆ | 4 | flake.nix 数据驱动 | ~60 行精简 |
| ★★☆ | 6 | 数据库客户端提 feature | 3 处重复消除 |
| ★★☆ | 7 | 去掉多余 mkMerge | 5 处简化 |
| ★★☆ | 8 | NixOS 用户配置共享 | 2 处合并 |
| ★☆☆ | 10 | 补充 _description | 文档质量 |
| ★☆☆ | 16 | 清理未使用 stable 输入 | flake 瘦身 |
| ☆☆☆ | 其余 | 风格一致性 | 可读性 |
