LS = {}

function LS.Active()
	local filename = "%f"
	local mod = "%m %r%h%w"
	local sep = " "
	local split = "%="
	local ft = vim.bo.filetype
	local git = "TODO"
	local line = "%c:%l/%L"
	local position = "%P"
	local encode = "%{&ff}"

	-- lsp {{{
	local lsp = "lsp"
	local lsp_server = function()
		local msg = ''
		local buf_ft = vim.bo.filetype
		local clients = vim.lsp.get_active_clients()
		if next(clients) == nil then
			return nil
		end
		for _, client in ipairs(clients) do
			local filetypes = client.config.filetypes
			if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
				-- return 'lsp: '..vim.fn.index(filetypes, buf_ft).." "..buf_ft.." "..client.name
				return client.name
			end
		end
		return msg
	end

	if lsp_server() ~= nil then
		lsp = string.format("%s", lsp_server())
	end

	-- }}}

	-- diagnostics {{{
	local _diag = vim.diagnostic.count(
		0, vim.diagnostic.get(1, {})
	)

	local diagnostics = ""

	if _diag[1] ~= nil then
		diagnostics = string.format("%s-%s", diagnostics, _diag[1])
	else
		diagnostics = string.format("%s-%s", diagnostics, "-")
	end

	if _diag[2] ~= nil then
		diagnostics = string.format("%s-%s", diagnostics, _diag[2])
	else
		diagnostics = string.format("%s-%s", diagnostics, "-")
	end

	if _diag[3] ~= nil then
		diagnostics = string.format("%s-%s", diagnostics, _diag[3])
	else
		diagnostics = string.format("%s-%s", diagnostics, "-")
	end

	if _diag[4] ~= nil then
		diagnostics = string.format("%s-%s", diagnostics, _diag[4])
	else
		diagnostics = string.format("%s-%s", diagnostics, "-")
	end

	if diagnostics ~= "" or diagnostics ~= nil then
		diagnostics = " "..diagnostics
	end
	-- }}}

	return string.format("%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
		filename,
		string.rep(sep, 1),
		mod,
		string.rep(split, 2),
		lsp,
		diagnostics,
		split,
		line,
		string.rep(sep, 2),
		encode,
		string.rep(sep, 2),
		git,
		string.rep(sep, 2),
		position,
		string.rep(sep, 2),
		ft,
		""
	)
end

LS.Inactive = LS.Active

function LS.Load(mode, colors)
	vim.opt.laststatus = 2
	vim.opt.showtabline = 2

	if colors == nil then
		colors = {}
	end

	if colors.fg_active == nil then
		colors.fg_active = "#bcbcbc"
	end

	if colors.bg_active == nil then
		colors.bg_active = "#282a2e"
	end

	if colors.fg_inactive == nil then
		colors.fg_inactive = "#777777"
	end

	if colors.bg_inactive == nil then
		colors.bg_inactive = "#000000"
	end

	vim.cmd(string.format("hi User1 ctermfg=black ctermbg=white guifg=%s guibg=%s cterm=NONE gui=NONE",
		colors.fg_active, colors.bg_active)
	)
	vim.cmd(string.format("hi User2 ctermfg=white ctermbg=black guifg=%s guibg=%s cterm=NONE gui=NONE",
		colors.fg_inactive, colors.bg_inactive)
	)

	vim.cmd [[
		hi! link StatusLine User1
		hi! link StatusLineNC User2
	]]


	if mode == "active" then
		vim.opt_local.statusline = LS.Active()
		vim.opt_local.tabline = "%F %= %b"
	else
		vim.opt_local.statusline = LS.Inactive()
		vim.opt_local.tabline = "%F %= %b"
	end
end

function LS.setup(config)
	local LS_augroup = vim.api.nvim_create_augroup("LS_augroup", {})
	local autocmd = vim.api.nvim_create_autocmd
	autocmd({"BufEnter", "WinEnter", "BufWinEnter", "BufWrite", "ModeChanged"}, {
		group = LS_augroup,
		pattern = "*",
		callback = function()
			LS.Load("active", config)
		end
	})

	autocmd({"WinLeave", "ModeChanged"}, {
		group = LS_augroup,
		pattern = "*",
		callback = function()
			LS.Load("inactive")
		end
	})
end

return LS
