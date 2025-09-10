-- Full LazyVim Configuration Examples
-- This file contains comprehensive examples of LazyVim plugin configurations
-- Copy and modify these snippets as needed for your own configuration

-- NOTE: This file is for reference only and is not loaded by LazyVim

-- ============================================================================
-- COLORSCHEME EXAMPLES
-- ============================================================================

-- Add and configure gruvbox colorscheme
local gruvbox_config = {
  { "ellisonleao/gruvbox.nvim" },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}

-- ============================================================================
-- LSP CONFIGURATION EXAMPLES
-- ============================================================================

-- Add pyright for Python development
local python_lsp = {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pyright = {},
    },
  },
}

-- TypeScript with typescript.nvim
local typescript_config = {
  "neovim/nvim-lspconfig",
  dependencies = {
    "jose-elias-alvarez/typescript.nvim",
    init = function()
      require("lazyvim.util").lsp.on_attach(function(_, buffer)
        vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
        vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
      end)
    end,
  },
  opts = {
    servers = {
      tsserver = {},
    },
    setup = {
      tsserver = function(_, opts)
        require("typescript").setup({ server = opts })
        return true
      end,
    },
  },
}

-- ============================================================================
-- TREESITTER CONFIGURATION
-- ============================================================================

-- Ensure specific parsers are installed
local treesitter_parsers = {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "bash",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "regex",
      "tsx",
      "typescript",
      "vim",
      "yaml",
    },
  },
}

-- Extend default parsers (additive approach)
local treesitter_extend = {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, {
      "tsx",
      "typescript",
    })
  end,
}

-- ============================================================================
-- UI ENHANCEMENTS
-- ============================================================================

-- Telescope configuration
local telescope_config = {
  "nvim-telescope/telescope.nvim",
  keys = {
    {
      "<leader>fp",
      function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
      desc = "Find Plugin File",
    },
  },
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
    },
  },
}

-- Lualine with custom components
local lualine_config = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_x, {
      function()
        return "😄"
      end,
    })
  end,
}

-- ============================================================================
-- COMPLETION ENHANCEMENTS
-- ============================================================================

-- Add emoji support to nvim-cmp
local cmp_emoji = {
  "hrsh7th/nvim-cmp",
  dependencies = { "hrsh7th/cmp-emoji" },
  opts = function(_, opts)
    table.insert(opts.sources, { name = "emoji" })
  end,
}

-- ============================================================================
-- DIAGNOSTICS AND DEBUGGING
-- ============================================================================

-- Configure trouble.nvim
local trouble_config = {
  "folke/trouble.nvim",
  opts = { use_diagnostic_signs = true },
}

-- Disable a plugin
local disable_plugin = {
  "folke/trouble.nvim",
  enabled = false,
}

-- ============================================================================
-- DEVELOPMENT TOOLS
-- ============================================================================

-- Mason tools installation
local mason_tools = {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "stylua",
      "shellcheck",
      "shfmt",
      "flake8",
    },
  },
}

-- ============================================================================
-- LAZYVIM EXTRAS
-- ============================================================================

-- Import LazyVim extras (these are pre-configured plugin sets)
local lazyvim_extras = {
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.json" },
  { import = "lazyvim.plugins.extras.ui.mini-starter" },
}

-- ============================================================================
-- COMPLETE CUSTOM CONFIGURATION EXAMPLE
-- ============================================================================

-- Example of a complete custom lualine configuration
local custom_lualine = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    return {
      options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    }
  end,
}

-- Export examples for reference (not actually used)
return {
  gruvbox = gruvbox_config,
  python_lsp = python_lsp,
  typescript = typescript_config,
  treesitter = treesitter_parsers,
  telescope = telescope_config,
  lualine = lualine_config,
  cmp_emoji = cmp_emoji,
  trouble = trouble_config,
  mason = mason_tools,
  extras = lazyvim_extras,
}