local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
local lspconfig = require "lspconfig"

-- list of all servers configured.
lspconfig.servers = {
  "bashls",
  "lua_ls",
  "basedpyright",
  "clangd",
  "rust_analyzer",
}

-- list of servers configured with default config.
local default_servers = {
  "html",
  "cssls",
  "vtsls",
  "marksman",
}

-- lsps with default config
for _, lsp in ipairs(default_servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

lspconfig.bashls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

lspconfig.lua_ls.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,

  settings = {
    Lua = {
      diagnostics = {
        enable = false, -- Disable all diagnostics from lua_ls
        -- globals = { "vim" },
      },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
          vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
          "${3rd}/love2d/library",
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}

lspconfig.basedpyright.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  on_init = on_init,
  settings = {
    basedpyright = {
      -- https://docs.basedpyright.com/#/configuration
      typeCheckingMode = "standard",
    },
  },
}

lspconfig.clangd.setup {
  -- on_attach = function(client, bufnr)
  --   client.server_capabilities.signatureHelpProvider = false
  --   on_attach(client, bufnr)
  -- end,
  -- capabilities = capabilities,
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--offset-encoding=utf-16",
  },
}

lspconfig.rust_analyzer.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      rustfmt = {
        extraArgs = { "+nightly" },
      },
    },
  },
}
