return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = true,

  -- 1) Zorg dat lazy.nvim de plugin laadt zodra je een Obsidian command uitvoert
  cmd = {
    "ObsidianNew",
    "ObsidianOpen",
    "ObsidianQuickSwitch",
    "ObsidianSearch",
    "ObsidianToday",
    "ObsidianYesterday",
    "ObsidianTomorrow",
    "ObsidianBacklinks",
    "ObsidianTags",
    "ObsidianTemplate",
  },

  -- (optioneel) je mag ft = "markdown" houden, maar het is niet meer nodig als je cmd gebruikt
  -- ft = "markdown",

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/personal",
      },
    },

    -- 2) Commands globaal beschikbaar maken (oplossing 1)
    commands = {
      ObsidianNew = { enabled = true },
      ObsidianOpen = { enabled = true },
      ObsidianQuickSwitch = { enabled = true },
      ObsidianSearch = { enabled = true },
      ObsidianToday = { enabled = true },
      ObsidianYesterday = { enabled = true },
      ObsidianTomorrow = { enabled = true },
      ObsidianBacklinks = { enabled = true },
      ObsidianTags = { enabled = true },
      ObsidianTemplate = { enabled = true },
    },
  },
}
