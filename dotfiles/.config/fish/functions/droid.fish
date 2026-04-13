function droid
    set -lx ZHIPU_API_KEY (gopass show -o ai/zhipu/key/opencode); or return 1
    set -lx KIMI_API_KEY (gopass show -o ai/kimi/coding/key/opencode); or return 1
    set -lx MINIMAX_API_KEY (gopass show -o ai/minimax/coding/key/default); or return 1
    command droid $argv
end
