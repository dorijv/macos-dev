require "nvchad.options"

-- add yours here!

vim.filetype.add {
  extension = { tf = "terraform", tfvars = "terraform", hcl = "hcl", tfstate = "json" },
  filename = { [".terraformrc"] = "hcl", ["terraform.rc"] = "hcl" },
  pattern = { [".*%.tfstate%.backup"] = "json" },
}
