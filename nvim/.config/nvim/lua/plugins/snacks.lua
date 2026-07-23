return {
  "folke/snacks.nvim",

  keys = {
    {
      "<leader>fd",
      function()
        Snacks.picker.files({
          cwd = vim.fn.stdpath("config"),
          hidden = true,
          ignored = true,
        })
      end,
      desc = "Find Dotfiles",
    },
  },
}
