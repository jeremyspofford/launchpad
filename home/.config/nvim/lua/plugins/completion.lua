-- Minimal completion enhancements - rely on LazyVim defaults
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "David-Kunz/cmp-npm", -- Just add npm completion for package.json
  },
  opts = {
    completion = {
      keyword_length = 0, -- Only change: trigger completion immediately
    },
  },
}