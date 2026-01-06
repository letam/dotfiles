vim.opt.conceallevel = 2

local dir_exists = function(p) return ((vim.uv or vim.loop).fs_stat(vim.fn.expand(p)) or {}).type == "directory" end

default_workspaces = {
    {
      name = "personal",
      path = "~/vaults/personal",
    },
    {
      name = "work",
      path = "~/vaults/work",
    },
}
present_workspaces = {}
is_workspace_present = false
for _, x in pairs(default_workspaces) do
  if dir_exists(x.path) then
    is_workspace_present = true
    table.insert(present_workspaces, x)
  end
end
if not is_workspace_present then
  print("obsidian.lua: No Obsidian workspace found.\nYou can create (or link to one) at '~/vaults/personal' or '~/vaults/workspace'.")
  return {}
end

return {
  "obsidian-nvim/obsidian.nvim",
  version = "*", -- use latest release, remove to use latest commit
  ft = "markdown",
  ---@module 'obsidian'
  ---@type obsidian.config
  opts = {
    legacy_commands = false, -- this will be removed in the next major release
    workspaces = present_workspaces,
    ui = { enable = false },  -- defer markdown rendering to render-markdown plugin instead
  },
}
