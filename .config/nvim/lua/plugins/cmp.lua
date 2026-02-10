return {
  -- Main completion plugin
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- LSP completion source
      'hrsh7th/cmp-nvim-lsp',

      -- Buffer completion source
      'hrsh7th/cmp-buffer',

      -- Path completion source
      'hrsh7th/cmp-path',

      -- Snippet engine (required by nvim-cmp)
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Snippet collection (optional, works with vim-snippets you already have)
      'rafamadriz/friendly-snippets',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      -- Load snippets from friendly-snippets
      require('luasnip.loaders.from_vscode').lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        mapping = cmp.mapping.preset.insert({
          -- Ctrl+n/p to navigate completion menu
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Ctrl+b/f to scroll docs
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Ctrl+Space to trigger completion
          ['<C-Space>'] = cmp.mapping.complete(),

          -- Ctrl+e to abort completion
          ['<C-e>'] = cmp.mapping.abort(),

          -- Enter to confirm selection
          ['<CR>'] = cmp.mapping.confirm({ select = true }),

          -- Tab to select next item or expand snippet
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),

          -- Shift+Tab to select previous item
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),

        sources = cmp.config.sources({
          { name = 'nvim_lsp' },    -- LSP completions (highest priority)
          { name = 'luasnip' },     -- Snippet completions
          { name = 'path' },        -- File path completions
        }, {
          { name = 'buffer' },      -- Buffer word completions (fallback)
        }),

        -- Completion menu appearance
        formatting = {
          format = function(entry, vim_item)
            -- Show source name in menu
            vim_item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snip]',
              buffer = '[Buf]',
              path = '[Path]',
            })[entry.source.name]
            return vim_item
          end,
        },

        -- Enable completion menu always
        experimental = {
          ghost_text = false,  -- Set to true for inline ghost text
        },
      })
    end,
  },
}
