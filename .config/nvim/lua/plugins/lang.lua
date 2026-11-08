-- Fedora-friendly language setup: no npm (pyright/jsonls) and no Go toolchain (gopls).
-- Python gets jedi-language-server for LSP plus ruff for linting/formatting;
-- the rest keep treesitter highlighting only.

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jedi_language_server = {},
      },
    },
  },

  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = { "ruff", "jedi-language-server" },
    },
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        python = { "ruff_format" },
      },
    },
  },

  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        python = { "ruff" },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "go", "json" })
    end,
  },
}
