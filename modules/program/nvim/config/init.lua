vim.opt.number = true
vim.opt.relativenumber = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function check_server_mode()
    -- 检查常见的 GUI 宿主变量
    if vim.g.vscode or vim.g.neovide or vim.g.goneovim then
        return true
    end
    -- 也可以检查是否作为 headless 启动
    if #vim.api.nvim_list_uis() == 0 then
        return true
    end
    return false
end

-- 定义全局开关变量 (ServerMode 表示只提供编辑逻辑，不提供 UI 装饰)
vim.g.IsServerMode = check_server_mode()

require("config.lazy")
require("config.keymaps")
require("config.server_opt")
