return {
  "obsidian-nvim/obsidian.nvim",

  lazy = true,
  ft = "markdown",

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  opts = {
    legacy_commands = false,

    workspaces = {
      {
        name = "obsidian",
        path = "~/obidian",
      },
    },

    notes_subdir = "00Inbox",
    new_notes_location = "notes_subdir",

    note_id_func = function(title, dir)
      return require("obsidian.builtin").title_id(title, dir)
    end,

    templates = {
      folder = "templates",
    },

    daily_notes = {
      folder = "00Inbox",
      template = "daily.md",
    },
  },
}
