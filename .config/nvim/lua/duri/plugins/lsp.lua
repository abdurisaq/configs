return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",  
        "saadparwaiz1/cmp_luasnip", 
    },
    config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {"lua_ls", "clangd","hls" },
            automatic_enable = false,
        })
        local cmp = require('cmp')
        local luasnip = require('luasnip')
        local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

        require('lspconfig').hls.setup{}
        require("lspconfig").lua_ls.setup{}
        require("lspconfig").clangd.setup{
            {
                capabilities = lsp_capabilities,
                cmd = { "clangd",
                    "-I", "/mnt/c/Program Files (x86)/Windows Kits/10/Include/10.0.22621.0/um",
                    "-I", "/mnt/c/Program Files (x86)/Windows Kits/10/Include/10.0.22621.0/shared",
                    "--compile-commands-dir=./" },
                filetypes = { "c", "cpp", "objc", "objcpp" },
                root_dir = require("lspconfig").util.root_pattern("compile_commands.json", ".git"),
                settings = {
                    clangd = {
                        compile_commands_dir = "./",
                    },
                },
            }
        }

        require("lspconfig").ts_ls.setup({
            capabilities = lsp_capabilities,
            on_attach = function(client, bufnr)
                -- Disable formatting with tsserver, because Prettier or other tools might handle formatting
                client.server_capabilities.document_formatting = false
            end
        })


        -- Configure nvim-cmp
        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },
            mapping = {
                -- Use Tab to navigate through completions
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),

                -- Use Shift-Tab to navigate backwards through completions
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),

                -- Accept the currently selected completion with Enter
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
            },
            sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'buffer' },
            },
        })
    end
}

