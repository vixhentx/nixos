if vim.g.IsServerMode then
    -- 1. 基础 UI 禁用（VS Code 不需要这些）
    vim.opt.showmode = false
    vim.opt.laststatus = 0
    vim.opt.ruler = false
    vim.opt.showcmd = false

    -- 2. 性能与重绘优化
    -- 注意：lazyredraw 在某些 GUI 下反而会导致光标闪烁，如果觉得光标跳动可以注释掉
    vim.opt.lazyredraw = true

    -- 3. 隐藏装饰符号 (修复 E474 错误)
    -- 使用字符串赋值比 table 更兼容，重点是 eob (End of Buffer)
    -- 我们只设置最核心的 eob，其余的交给宿主控制
    pcall(function()
        vim.opt.fillchars = "eob: ,fold: ,foldsep: "
    end)

    -- 4. 禁用匹配括号高亮 (VS Code 已经自带且更强)
    -- 这通常是导致删除行时“字符残留”的元凶之一
    vim.g.loaded_matchparen = 1
    
    -- 5. 禁用各种提示声音/闪烁
    vim.opt.visualbell = false
    vim.opt.errorbells = false
end
