LS = {}

-- StatusActive {{{
function LS.StatusActive()
	local filename = "%f"
	local mod = "%m %r%h%w"
	local sep = " "
	local split = "%="
	local line = "%c:%l/%L"
	local position = "%P"
	local encode = "%{&ff}"

	-- lsp {{{
	local lsp = ""
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
				return "  "..client.name
			end
		end
		return msg
	end

	if lsp_server() ~= nil then
		lsp = string.format("%s", lsp_server())
	end

	-- }}}

	-- diagnostics {{{

	local _diag = {
		#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }),
		#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN }),
		#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO }),
		#vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT }),
	}

	local diagnostics = ""

	if _diag[1] ~= 0 then
		diagnostics = string.format("%s-%s", diagnostics, _diag[1])
	else
		diagnostics = string.format("%s-%s", diagnostics, "-")
	end

	if _diag[2] ~= 0 then
		diagnostics = string.format("%s-%s", diagnostics, _diag[2])
	else
		diagnostics = string.format("%s-%s", diagnostics, "-")
	end

	if _diag[3] ~= 0 then
		diagnostics = string.format("%s-%s", diagnostics, _diag[3])
	else
		diagnostics = string.format("%s-%s", diagnostics, "-")
	end

	if _diag[4] ~= 0 then
		diagnostics = string.format("%s-%s", diagnostics, _diag[4])
	else
		diagnostics = string.format("%s-%s", diagnostics, "-")
	end

	if diagnostics ~= "" or diagnostics ~= nil then
		diagnostics = " "..diagnostics
	end
	-- }}}

	return string.format("%s%s%s%s%s%s%s%s%s%s%s%s%s%s",
		filename,
		string.rep(sep, 1),
		mod,
		string.rep(sep, 2),
		split,
		line,
		string.rep(sep, 1),
		position,
		string.rep(sep, 3),
		encode,
		string.rep(sep, 3),
		vim.bo.filetype,
		lsp,
		diagnostics
	)
end
-- }}}

-- -- TabActive {{{
-- function LS.TabActive()
-- 	local encode = "%{&ff}"
--
--
-- 	-- -- local buffers = #vim.api.nvim_list_bufs()
-- 	-- local bufs = 0
-- 	-- for k,v in ipairs(vim.api.nvim_list_bufs()) do
-- 	-- 	if vim.api.nvim_buf_is_loaded(v) then
-- 	-- 	-- if vim.api.nvim_buf_line_count(v) ~= 0 then
-- 	-- 		bufs = bufs + 1
-- 	-- 	end
-- 	-- end
-- 	-- bufs = bufs - 1 -- for the default buffer :/
--
-- 	vim.cmd([[
-- 		hi! link StatusLineNC User2
-- 		hi! link TabLine User1
-- 		hi! link TabLinSel User2
-- 	]])
--
-- 	return string.format("%s%s%s%s%s%s%s%s%s",
-- 		"%b %F",
-- 		string.rep(" ", 2),
-- 		lsp,
-- 		diagnostics,
-- 		"%=",
-- 		string.rep(" ", 2),
-- 		git,
-- 		string.rep(" ", 4),
-- 		encode,
-- 		""
-- 	)
-- end
-- -- }}}

-- StatusInactive {{{
LS.StatusInactive = LS.StatusActive
-- }}}

-- Load {{{
function LS.Load(mode, colors)
	vim.opt.laststatus = 2
	vim.opt.showtabline = 1 -- yeah maybe

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
		hi! link TabLinSel User1
		hi! link TabLineFill User2
		hi! link TabLine User2
	]]


	if mode == "active" then
		vim.opt_local.statusline = LS.StatusActive()
		-- vim.opt_local.tabline = LS.TabActive()
	else
		vim.opt_local.statusline = LS.StatusInactive()
		-- vim.opt_local.tabline = LS.TabActive()
		-- vim.opt_local.tabline = "%F %= %b"
	end

end
-- }}}

-- setup {{{
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
-- }}}

return LS
