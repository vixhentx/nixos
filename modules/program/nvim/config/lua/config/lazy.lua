-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local lazy = require("lazy")

-- Setup lazy.nvim
lazy.setup({
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "catppuccin", "habamax" } },
  -- automatically check for plugin updates
  checker = {
    enabled = not vim.g.IsServerMode,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})

if not vim.g.IsServerMode then
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    once = true,
    callback = function()
      vim.defer_fn(function()
        if vim.v.exiting ~= vim.NIL then
          return
        end

        local runner = lazy.update({ show = false, wait = false })
        if not runner then
          return
        end

        runner:wait(vim.schedule_wrap(function()
          local config = require("lazy.core.config")
          local plugin = require("lazy.core.plugin")
          local failed = {}

          for _, item in pairs(config.plugins) do
            if plugin.has_errors(item) then
              failed[#failed + 1] = item.name
            end
          end

          if #failed > 0 then
            table.sort(failed)
            vim.notify(
              "Plugin auto-update failed: " .. table.concat(failed, ", "),
              vim.log.levels.ERROR,
              { title = "lazy.nvim" }
            )
          end
        end))
      end, 1000)
    end,
  })
end
