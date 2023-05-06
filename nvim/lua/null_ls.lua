-- null-ls.nvim
-- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
-- Reference: https://github.com/jose-elias-alvarez/null-ls.nvim

local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		-- null_ls.builtins.formatting.stylua,
		-- null_ls.builtins.diagnostics.eslint,
		-- null_ls.builtins.completion.spell,

		-- Python/Django/Jinja/Flask
		null_ls.builtins.formatting.black,
		null_ls.builtins.formatting.djhtml,
		null_ls.builtins.formatting.djlint,
		null_ls.builtins.diagnostics.ruff,
	},
})
