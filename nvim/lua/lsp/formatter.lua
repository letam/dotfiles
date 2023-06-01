-- Formatter-related setup

-- Uses null-ls.nvim - Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
-- Reference: https://github.com/jose-elias-alvarez/null-ls.nvim
-- Reference for built-in sources: https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md

local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		-- null_ls.builtins.formatting.stylua,
		-- null_ls.builtins.diagnostics.eslint,
		-- null_ls.builtins.completion.spell,

		-- Prettier (javascript, react, typescript, css, scss, json, graphql, markdown, yaml, html, vue, handlebars)
		-- null_ls.builtins.formatting.prettierd,
		null_ls.builtins.formatting.prettierd.with({
			-- filetypes={ "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "css", "scss", "less", "html", "json", "jsonc", "yaml", "markdown", "markdown.mdx", "graphql", "handlebars" }
			filetypes={ "vue", "css", "scss", "less", "html", "jsonc", "yaml", "markdown", "markdown.mdx", "graphql", "handlebars" }
		}),

		-- Rome (Formatter, linter, bundler, and more for JavaScript, TypeScript, JSON, HTML, Markdown, and CSS.)
			-- Note: Currently supports only JavaScript, TypeScript, JSON
		null_ls.builtins.formatting.rome.with({
			filetypes={ "javascript", "typescript", "javascriptreact", "typescriptreact", "json" }
		}),

		-- Python/Django/Jinja/Flask
		null_ls.builtins.formatting.black.with({
			extra_args = { "--skip-string-normalization" },
		}),
		null_ls.builtins.formatting.isort,
		null_ls.builtins.formatting.djhtml,
		null_ls.builtins.formatting.djlint,
		null_ls.builtins.diagnostics.ruff,
	},

	-- Trigger to format automatically upon save
	-- Reference: https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save
	-- you can reuse a shared lspconfig on_attach callback here
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
					-- vim.lsp.buf.formatting_sync()
					vim.lsp.buf.format({ bufnr = bufnr })
				end,
			})
		end
	end,
})

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- Filter LSP formatters so that only null-ls receives the formatting request
-- Reference: https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Formatting-on-save#choosing-a-client-for-formatting
local callback = function()
	vim.lsp.buf.format({
		bufnr = bufnr,
		filter = function(client)
			return client.name == "null-ls"
		end
	})
end
