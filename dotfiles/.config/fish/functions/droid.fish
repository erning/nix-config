function droid
    set -lx ZHIPU_API_KEY (rspass show ai/zhipu/key/opencode); or return 1
    set -lx KIMI_API_KEY (rspass show ai/kimi/coding/key/opencode); or return 1
    set -lx MINIMAX_API_KEY (rspass show ai/minimax/coding/key/default); or return 1
    command droid $argv
end
