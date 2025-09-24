-- -- Basic settings
-- vim.opt.number = true
-- vim.opt.relativenumber = true
-- vim.opt.expandtab = true
-- vim.opt.shiftwidth = 2
-- vim.opt.tabstop = 2
-- vim.opt.smartindent = true
-- vim.opt.wrap = false
-- vim.opt.ignorecase = true
-- vim.opt.smartcase = true

-- -- Leader key
-- vim.g.mapleader = " "

-- -- Load AWS CDK configuration
-- require('aws-cdk').setup()

-- -- Auto-format on save for TypeScript files
-- vim.api.nvim_create_autocmd("BufWritePre", {
--   pattern = {"*.ts", "*.js"},
--   callback = function()
--     vim.lsp.buf.format({ async = false })
--   end,
-- })

require("config.lazy")
