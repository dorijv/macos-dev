return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "hashivim/vim-terraform",
    ft = "terraform",
    config = function()
      vim.g.terraform_fmt_on_save = 1
      vim.g.terraform_align = 1
      vim.g.hcl_align = 1
    end,
  },

  {
    "infracost/infracost.nvim",
    ft = { "terraform", "hcl" }, -- NvChad lazy-loads by default, so it needs a trigger
    opts = {},
  },
}
