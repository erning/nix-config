-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Save readonly files with :w!! via sudo.
vim.cmd([[cnoreabbrev <expr> w!! getcmdtype() ==# ':' && getcmdline() ==# 'w!!' ? 'w !sudo tee % >/dev/null' : 'w!!']])
