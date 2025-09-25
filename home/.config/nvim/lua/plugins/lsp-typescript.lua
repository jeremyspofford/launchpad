-- Minimal TypeScript enhancements - rely on LazyVim defaults
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {
        settings = {
          typescript = {
            preferences = {
              -- Only enhance auto-imports for better CDK experience
              includePackageJsonAutoImports = "on",
              includeCompletionsForModuleExports = true,
            },
          },
        },
      },
    },
  },
}
