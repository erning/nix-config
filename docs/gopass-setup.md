# gopass 初始化指南

新机器上的 gopass 启动步骤。`gopass` 和 `age` 已由 `home-manager/features/gopass.nix` 装好，
这里只记录密钥和 store 的初始化流程。

## 关键信息

- **后端**：age（非 GPG）
- **配置路径**：`~/.config/gopass/config`
- **身份文件**：`~/.config/gopass/age/identities`
  —— **gopass 强制 scrypt 加密**（`decryptFile` 固定走 `age.NewScryptIdentity`），不能手工粘贴明文 `AGE-SECRET-KEY-1...`，必须通过 `gopass age identities add` 写入
- **store 根目录**：`~/.local/share/gopass/stores/`
- **当前 store 布局**：
  - `root` — 本地 store，无远端，主要是用来挂 `ai` 的壳
  - `ai` — 挂载在 `ai/`，远端 `git@github.com:erning/gopass-ai.git`
- **路径前缀不要改**：`dotfiles/.config/cce/*.env` 里写死 `gopass show -o ai/kimi/...`，所以必须保留 root + ai 的两层结构

## 密钥位置

| 密钥 | 用途 | 存放位置 |
|---|---|---|
| **primary** `age1ggjtry...` | 跨主机的主 recipient | **1Password**（私钥），公钥在 `nix-secrets/keys.nix` |
| **bootstrap** `age1qnl9d2u...` | `ai` store 的额外 recipient | `nix-secrets/keys.nix` |
| **host** 公钥 | agenix 主机身份，**同时也是 `ai` store 的 recipient** | `nix-secrets/age/<host>.pub`，私钥在系统里 `/etc/age/ssh_host_ed25519.txt`（`modules/secrets.nix` 的 activation script 自动生成） |

> primary 私钥只存在 1Password，不在任何仓库里。host key 是每台机器系统激活时从 ssh host key 自动派生的（`ssh-to-age -private-key`），没有 passphrase，重装系统即失效。

## 身份策略：两种方案

| 维度 | A. host age key | B. primary age key |
|---|---|---|
| 私钥来源 | 本机 `/etc/age/ssh_host_ed25519.txt`（agenix 自动生成） | 1Password |
| recipient 范围 | 仅这台机器 | 所有持有 primary 的机器 |
| 授权新机器 | 在已有机器上 `gopass recipients add --store ai <host-pub>` 一次 | 无需（primary 已经是 recipient） |
| 重装影响 | host key 变，需要重新授权 | 只要 1Password 能登回去就能恢复 |
| 适合 | 长期在位的机器、希望和 agenix 共用同一身份 | 临时机器、不想往 store 里加更多 recipient |

两种方案可以共存 —— identities 文件里可以同时存多把私钥。

## 新机器初始化

前提：nix 已经 switch 过一次，`/etc/age/ssh_host_ed25519.txt` 已经被 `modules/secrets.nix` 的 activation script 自动生成。

流程：**注册 identity → `gopass setup` → `gopass clone`**。

### 方案 A：用本机 host age key（推荐）

> `ai` store 已经把 `nix-secrets/age/*.pub` 里**所有主机**的 host 公钥都加为 recipient 了。只要这台机器已经在 nix-secrets 里（`nix-secrets/age/<host>.pub` 存在、secrets.nix 里登记过、`just rekey` 跑过），就不需要再单独授权一次 —— 直接进步骤 1 即可。
>
> 如果这是一台**全新的、还没进 nix-secrets 的机器**，先按 `~/projects/nix-secrets/README.md` 的流程 `just scankey <hostname> <address>`、补 `secrets.nix`、`just rekey`，然后在任一已有机器上：
>
> ```fish
> gopass recipients add --store ai (cat ~/projects/nix-secrets/age/<host>.pub)
> gopass sync --store ai
> ```
>
> 把新主机的 host 公钥加到 `ai` 的 recipient 列表里（会触发 rekey，重新加密现有 secret）。以后这台机器就和其他的机器一样，走下面同一个步骤即可。

**步骤 1：在新机器上完成 gopass 初始化**

```fish
# 打开 age-agent（默认是 false，见 config.go:50）
# 不开的话每次 gopass 调用都要重新读 identities 文件、重新弹 pinentry
gopass config age.agent-enabled true

# 注册 host 私钥到 gopass native identities
# ssh-to-age -private-key 输出是单行 AGE-SECRET-KEY-1...，cat 就够用
# 文件已经是用户可读的（home-manager agenix 就靠这个，见 home-manager/secrets.nix）
gopass age identities add "$(cat /etc/age/ssh_host_ed25519.txt)"
#   → pinentry 会让你设一个 scrypt passphrase
#     这是 gopass identities 文件的加密密码，跟 host key 无关，随便设
#     之后的 gopass 操作都靠 agent 缓存这个 passphrase，每次登录 session 只输一次

# 初始化本地 root store
gopass setup --crypto age
#   → Welcome / 配置 store
#   → "Please select a private key..." —— identities 里只有一把就直接用，
#     不会交互式问你选（cui/recipients.go:46 的 shortcut）
#   → "Do you want to add a git remote?" → 回 N（root store 本地就行）
#   → 结束

# clone ai 作为 sub-store
gopass clone --crypto age git@github.com:erning/gopass-ai.git ai
#   → 会走 cloneCheckDecryptionKeys，ListIdentities 能看到 host key，
#     验证通过后自动 rekey check
```

**步骤 2：验证**

```fish
gopass mounts                                         # 应列出 root 和 ai
gopass show -o ai/kimi/coding/key/claude-code | head -c 8
```

### 修改 identities passphrase

gopass 没有内置改密码命令。identities 文件是标准的 age scrypt 加密文件，直接解密再重新加密即可：

```bash
f=~/.config/gopass/age/identities
age -d "$f" | age -p -o "$f.new"   # 输旧密码 → 输新密码
mv "$f.new" "$f"
```

### 方案 B：用 primary age key

如果这台机器想用 1Password 里的 primary 私钥（跨主机通用那把），只把步骤 1 的 identities add 换成交互式添加：

```fish
gopass age identities add
#   → "the age identity starting in AGE-": 粘贴 1Password 里的 AGE-SECRET-KEY-1...
#   → pinentry 设一个 scrypt passphrase

gopass setup --crypto age
gopass clone --crypto age git@github.com:erning/gopass-ai.git ai
```

primary 公钥本来就是 `ai` / `root` 的 recipient，所以不需要"步骤 1 授权"那一步。
