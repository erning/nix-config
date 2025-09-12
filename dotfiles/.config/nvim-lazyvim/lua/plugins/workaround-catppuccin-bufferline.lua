-- fix(catppuccin): follow renamed integration
--
-- https://github.com/LazyVim/LazyVim/pull/6354
-- > https://github.com/LazyVim/LazyVim/pull/6354#issuecomment-3202799735
-- > Should be fixed in LazyVim, and here's a workaround until LazyVim
-- > accepts PRs.
--
-- https://github.com/catppuccin/nvim/issues/923

return {
  {
    "akinsho/bufferline.nvim",
    init = function()
      local bufline = require("catppuccin.groups.integrations.bufferline")
      function bufline.get()
        return bufline.get_theme()
      end
    end,
  }
}
