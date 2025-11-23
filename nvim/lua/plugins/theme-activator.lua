return {
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      -- 1. Create an Autocmd that runs AFTER startup is finished
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Try to load the theme
          local status_ok, error_msg = pcall(require, "current_theme")

          -- If it fails, fallback to habamax and notify
          if not status_ok then
            vim.notify("Theme Switcher Error: " .. tostring(error_msg), vim.log.levels.ERROR)
          end
        end,
      })
    end,
  },
}
