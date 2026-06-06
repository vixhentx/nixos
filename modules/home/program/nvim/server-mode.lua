-- Runtime server mode detection.
-- Overrides vim.g.IsServerMode set at build time with more accurate
-- runtime checks.  VSCode / Neovide / Goneovim / headless all count
-- as "server mode" and should load only the editing core, not the UI.

local function check_server_mode()
  -- GUI hosts that provide their own UI
  if vim.g.vscode or vim.g.neovide or vim.g.goneovim then
    return true
  end
  -- Headless (batch scripts, tests, nvimpager, etc.)
  if #vim.api.nvim_list_uis() == 0 then
    return true
  end
  return false
end

-- Re-evaluate at runtime so that build-time defaults are corrected
-- when the actual runtime context differs (e.g.  build-time
-- serverMode=false but the user opened nvim inside VSCode).
vim.g.IsServerMode = check_server_mode()
