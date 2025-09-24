return {

  -- AWS CDK specific configuration and commands
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "typescript",
        "javascript", 
        "json",
        "yaml",
        "dockerfile",
        "bash",
      },
    },
  },

  -- CDK project detection and commands  
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}
      vim.list_extend(opts.spec, {
        { "<leader>c", group = "CDK" },
        { "<leader>cd", "<cmd>CdkDiff<cr>", desc = "CDK Diff" },
        { "<leader>cp", "<cmd>CdkDeploy<cr>", desc = "CDK Deploy" },
        { "<leader>cs", "<cmd>CdkSynth<cr>", desc = "CDK Synth" },
        { "<leader>cx", "<cmd>CdkDestroy<cr>", desc = "CDK Destroy" },
        { "<leader>cb", "<cmd>CdkBootstrap<cr>", desc = "CDK Bootstrap" },
        { "<leader>cl", "<cmd>CdkList<cr>", desc = "CDK List Stacks" },
        { "<leader>cR", "<cmd>CdkRefreshLsp<cr>", desc = "Refresh CDK LSP" },
      })
      return opts
    end,
  },

  -- CDK utilities and autocommands
  {
    "LazyVim/LazyVim",
    opts = {},
    config = function()
      -- CDK file associations
      vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        pattern = {"cdk.json", "cdk.context.json"},
        callback = function()
          vim.bo.filetype = "json"
        end,
      })

      -- CDK project detection and setup
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          local cwd = vim.fn.getcwd()
          if vim.fn.filereadable(cwd .. "/cdk.json") == 1 then
            vim.notify("🚀 AWS CDK project detected!", vim.log.levels.INFO)
            
            -- Set up CDK-specific settings
            vim.g.cdk_project = true
            
            -- Add CDK node_modules to path for better completions
            local node_modules = cwd .. "/node_modules"
            if vim.fn.isdirectory(node_modules) == 1 then
              vim.opt.path:append(node_modules)
              
              -- Also check for common CDK packages to ensure they're installed
              local cdk_lib_path = node_modules .. "/aws-cdk-lib"
              local constructs_path = node_modules .. "/constructs"
              
              if vim.fn.isdirectory(cdk_lib_path) == 0 or vim.fn.isdirectory(constructs_path) == 0 then
                vim.notify("⚠️  CDK dependencies not found. Run 'npm install' to enable full autocompletion.", vim.log.levels.WARN)
              else
                vim.notify("✅ CDK dependencies found. Full autocompletion enabled!", vim.log.levels.INFO)
                
                -- Force TypeScript LSP to refresh and pick up CDK types
                vim.defer_fn(function()
                  local clients = vim.lsp.get_active_clients({ name = "tsserver" })
                  for _, client in ipairs(clients) do
                    if client.server_capabilities.workspaceSymbolProvider then
                      -- Restart the LSP to pick up CDK types
                      vim.cmd("LspRestart tsserver")
                    end
                  end
                end, 2000)
              end
            end
          end
        end,
      })
      
      -- Enhanced CDK file detection for better LSP integration
      vim.api.nvim_create_autocmd({"BufEnter", "BufRead"}, {
        pattern = {"*.ts", "*.js"},
        callback = function()
          if vim.g.cdk_project then
            -- CDK project detected - LSP should handle completions
            -- Additional CDK-specific buffer setup can go here
          end
        end,
      })

      -- CDK commands
      vim.api.nvim_create_user_command('CdkDiff', function(opts)
        local stack = opts.args ~= "" and opts.args or ""
        vim.cmd('terminal cdk diff ' .. stack)
      end, { nargs = '?', complete = 'file' })

      vim.api.nvim_create_user_command('CdkDeploy', function(opts)
        local stack = opts.args ~= "" and opts.args or ""
        vim.cmd('terminal cdk deploy ' .. stack)
      end, { nargs = '?', complete = 'file' })

      vim.api.nvim_create_user_command('CdkSynth', function(opts)
        local stack = opts.args ~= "" and opts.args or ""
        vim.cmd('terminal cdk synth ' .. stack)
      end, { nargs = '?', complete = 'file' })

      vim.api.nvim_create_user_command('CdkDestroy', function(opts)
        local stack = opts.args ~= "" and opts.args or ""
        vim.cmd('terminal cdk destroy ' .. stack)
      end, { nargs = '?', complete = 'file' })

      vim.api.nvim_create_user_command('CdkBootstrap', function()
        vim.cmd('terminal cdk bootstrap')
      end, {})

      vim.api.nvim_create_user_command('CdkList', function()
        vim.cmd('terminal cdk list')
      end, {})

      -- Command to refresh CDK LSP completions
      vim.api.nvim_create_user_command('CdkRefreshLsp', function()
        vim.notify("🔄 Refreshing TypeScript LSP for CDK...", vim.log.levels.INFO)
        vim.cmd("LspRestart tsserver")
        vim.defer_fn(function()
          vim.notify("✅ LSP refreshed! CDK completions should now work.", vim.log.levels.INFO)
        end, 3000)
      end, {})

      -- CDK-specific snippets and abbreviations
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {"typescript", "javascript"},
        callback = function()
          if vim.g.cdk_project then
            -- Common CDK abbreviations
            vim.cmd([[iabbrev <buffer> cdkstack import * as cdk from 'aws-cdk-lib';]])
            vim.cmd([[iabbrev <buffer> cdkapp const app = new cdk.App();]])
            vim.cmd([[iabbrev <buffer> cdkconstruct import { Construct } from 'constructs';]])
          end
        end,
      })
    end,
  },
}
