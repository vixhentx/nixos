-- lua/config/keymaps.lua
local keymap = vim.keymap.set
local is_server = vim.g.IsServerMode

if is_server then
    if vim.g.vscode then
        -- VS Code 专用快捷键
        keymap("n", "<leader>ff", "<Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>")
        keymap("n", "<leader>/", "<Cmd>call VSCodeNotify('editor.action.commentLine')<CR>")
    end
else
    -- 终端模式：使用插件命令
    keymap("n", "<leader>ff", ":Telescope find_files<CR>")
    keymap("n", "<leader>fg", ":Telescope live_grep<CR>")
    -- ... 其他 Telescope 映射
    keymap("n", "<leader>e", ":NvimTreeToggle<CR>")
end
