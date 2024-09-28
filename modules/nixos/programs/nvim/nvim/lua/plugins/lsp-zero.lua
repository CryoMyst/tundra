local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.on_attach(function(client, bufnr)
    lsp.default_keymaps({buffer = bufnr})
end)

-- When you don't have mason.nvim installed
-- You'll need to list the servers installed in your system
lsp.setup_servers({
    'omnisharp',
    'rust_analyzer',
})
lsp.setup()

local lspconfig = require("lspconfig")
lspconfig.rust_analyzer.setup({
    settings = {
        ["rust-analyzer"] = {
            -- checkOnSave = {
            --     command = vim.g.nix.clippy.path;
            -- }
        }
    };
});
lspconfig.omnisharp.setup({
    cmd = { "OmniSharp" };
});
