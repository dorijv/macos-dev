-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "catppuccin",

  hl_add = {
    ["@comment"] = { link = "Comment" },
    ["@comment.lua"] = { fg = "white" },
    ["@comment.python"] = { fg = "red" },
    ["@comment.terraform"] = { fg = "white" },
    ["@comment.hcl"] = { fg = "white" },
  },
}

return M
