return {
  {
    "shortcuts/no-neck-pain.nvim",
    config = function()
      require("no-neck-pain").setup({
        buffers = {
          scratchpad = {
            enabled = true,
            location = "~/Documents/",
          },
          bo = {
            filetype = "md",
          },
        },
      })
    end,
  },
}
