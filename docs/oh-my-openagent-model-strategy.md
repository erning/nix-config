# oh-my-openagent 模型分配策略

本文档记录 `dotfiles/.config/opencode/oh-my-openagent.json` 的模型分配原则。配置目标是让不同 agent/category 使用符合任务形态的主模型，并通过有序 fallback 降低单一 provider 不可用时的失败率。

## 总体原则

- `fallback_models` 有顺序，按数组从前到后尝试。
- Kimi K2.6 是通用、编排、写作和视觉/前端的主力模型。
- GPT-5.4 负责深度实现、架构判断和审查类任务。
- GLM-5.1 负责检索、探索、快速任务，并作为非多模态链路的次级 fallback。
- Gemini Pro/Flash 只放在视觉/前端和写作相关链路；GLM-5.1 不放入多模态 fallback。

## 模型角色

| 模型 | 角色 |
|---|---|
| `kimi-for-coding/k2p6` | 编排、通用编码、写作、视觉/前端主模型；也是多数非多模态 GPT/GLM 链路的 fallback |
| `openai/gpt-5.4` | 深度实现、架构分析、复杂审查 |
| `zhipuai-coding-plan/glm-5-turbo` | 检索、探索 |
| `zhipuai-coding-plan/glm-5.1` | 快速任务、非多模态次级 fallback |
| `openai/gpt-5.4-mini-fast` | 检索/探索在 GLM-5.1 不可用时的轻量 fallback，排在 Kimi 前面 |
| `google/antigravity-gemini-3.1-pro` | 复杂视觉/前端 fallback |
| `google/antigravity-gemini-3.1-flash` | 多模态查看、写作 fallback |

## Agent 分配

| Agent | 主模型 | Fallback 顺序 | 用途 |
|---|---|---|---|
| `sisyphus` | `kimi-for-coding/k2p6` | `zhipuai-coding-plan/glm-5.1` -> `openai/gpt-5.4` medium | 编排/通用 |
| `hephaestus` | `openai/gpt-5.4` medium | `kimi-for-coding/k2p6` -> `zhipuai-coding-plan/glm-5.1` | 深度实现 |
| `oracle` | `openai/gpt-5.4` high | `kimi-for-coding/k2p6` -> `zhipuai-coding-plan/glm-5.1` | 架构、调试、咨询 |
| `librarian` | `zhipuai-coding-plan/glm-5-turbo` | `openai/gpt-5.4-mini-fast` -> `kimi-for-coding/k2p6` | 检索 |
| `explore` | `zhipuai-coding-plan/glm-5-turbo` | `openai/gpt-5.4-mini-fast` -> `kimi-for-coding/k2p6` | 探索 |
| `multimodal-looker` | `kimi-for-coding/k2p6` | `google/antigravity-gemini-3.1-flash` medium | 多模态查看 |
| `prometheus` | `kimi-for-coding/k2p6` | `zhipuai-coding-plan/glm-5.1` -> `openai/gpt-5.4` medium | 通用规划/执行 |
| `metis` | `openai/gpt-5.4` high | `kimi-for-coding/k2p6` -> `zhipuai-coding-plan/glm-5.1` | 架构判断 |
| `momus` | `openai/gpt-5.4` xhigh | `kimi-for-coding/k2p6` -> `zhipuai-coding-plan/glm-5.1` | 严格审查 |
| `atlas` | `kimi-for-coding/k2p6` | `zhipuai-coding-plan/glm-5.1` -> `openai/gpt-5.4` medium | 通用任务 |

## Category 分配

| Category | 主模型 | Fallback 顺序 | 用途 |
|---|---|---|---|
| `visual-engineering` | `kimi-for-coding/k2p6` | `google/antigravity-gemini-3.1-pro` high | 视觉/前端 |
| `ultrabrain` | `openai/gpt-5.4` xhigh | `kimi-for-coding/k2p6` -> `zhipuai-coding-plan/glm-5.1` | 最高复杂度推理 |
| `deep` | `openai/gpt-5.4` high | `kimi-for-coding/k2p6` -> `zhipuai-coding-plan/glm-5.1` | 深度实现 |
| `artistry` | `kimi-for-coding/k2p6` | `google/antigravity-gemini-3.1-pro` high | 视觉/创意实现 |
| `quick` | `zhipuai-coding-plan/glm-5.1` | `kimi-for-coding/k2p6` | 快速任务 |
| `unspecified-low` | `kimi-for-coding/k2p6` | `zhipuai-coding-plan/glm-5.1` -> `openai/gpt-5.4` medium | 默认低复杂度 |
| `unspecified-high` | `kimi-for-coding/k2p6` | `zhipuai-coding-plan/glm-5.1` -> `openai/gpt-5.4` high | 默认高复杂度 |
| `writing` | `kimi-for-coding/k2p6` | `zhipuai-coding-plan/glm-5.1` -> `google/antigravity-gemini-3.1-flash` medium | 写作 |

## 并发策略

并发限制用于避免 ultrawork 或多 agent 工作流同时打满单一 provider。

上游文档给出的 background task 示例包含：

```json
{
  "background_task": {
    "defaultConcurrency": 5,
    "staleTimeoutMs": 180000,
    "providerConcurrency": {
      "anthropic": 3,
      "openai": 5,
      "google": 10
    },
    "modelConcurrency": {
      "anthropic/claude-opus-4-7": 2
    }
  }
}
```

上游规则是 `modelConcurrency > providerConcurrency > defaultConcurrency`。当前配置采用上游示例中的 `defaultConcurrency = 5` 和 `staleTimeoutMs = 180000`，然后按本仓库的模型分配策略下调重模型并发、放宽轻量或工具型模型并发。

| Provider/Model | 并发 |
|---|---:|
| default | 5 |
| stale timeout | 180000 ms |
| `openai` | 3 |
| `google` | 5 |
| `kimi-for-coding` | 3 |
| `zhipuai-coding-plan` | 5 |
| `openai/gpt-5.4` | 2 |
| `openai/gpt-5.4-mini-fast` | 8 |
| `kimi-for-coding/k2p6` | 3 |
| `zhipuai-coding-plan/glm-5-turbo` | 5 |

数值推导：

- `openai/gpt-5.4 = 2`：GPT-5.4 负责深度实现、架构和审查，属于高成本/高延迟重模型，按上游“限制昂贵模型”的原则压低并发。
- `openai = 3`：OpenAI provider 包含 GPT-5.4 主链路，provider 层整体比上游示例 `openai = 5` 更保守。
- `openai/gpt-5.4-mini-fast = 8`：只作为检索/探索 fallback 的轻量模型，允许更高并发。
- `kimi-for-coding/k2p6 = 3`：Kimi 是通用、编排、写作和部分视觉链路主力，覆盖面广，使用中等并发避免被 ultrawork 同时打满。
- `zhipuai-coding-plan/glm-5-turbo = 5`：GLM-5 Turbo 负责检索和探索，任务相对轻，允许比 GPT/Kimi 更高的并发。GLM-5.1 用于 quick 和非多模态 fallback，不单独设置 model concurrency。
- `google = 5`：Google 主要是视觉/前端和写作 fallback，不是主路径；比上游示例 `google = 10` 更保守。

## 维护规则

- 调整模型时先改 `dotfiles/.config/opencode/oh-my-openagent.json`，再同步更新本文档。
- 多模态链路只使用明确支持图像输入的模型，不把 GLM-5.1 加入视觉 fallback。
- 新增 fallback 时保持顺序有意义：优先尝试同任务类型的轻量或主力替代模型，最后再兜底到泛用模型。
- 修改后运行 `jq empty dotfiles/.config/opencode/oh-my-openagent.json` 校验 JSON。
