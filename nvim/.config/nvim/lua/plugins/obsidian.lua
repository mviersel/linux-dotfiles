return {
  "obsidian-nvim/obsidian.nvim",
  lazy = true,

  cmd = {
    "Obsidian",
  },

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

    note_id_func = function(title, path)
      print("OBSIDIAN TITLE:", vim.inspect(title))

      if title and title ~= "" then
        return title
      end

      return tostring(os.time())
    end,

    templates = {
      folder = ".templates",
    },

    daily_notes = {
      folder = "00Inbox",
      template = "daily.md",
    },

    follow_url_func = vim.ui.open,
  },
}
