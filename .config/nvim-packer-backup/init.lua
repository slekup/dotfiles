vim.opt.termguicolors = true

require("core.plugins")
require("core.keymaps")
require("colorizer-config")
require("comment-config")

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.backspace = '2'
vim.opt.showcmd = true
vim.opt.laststatus = 2
vim.opt.autowrite = true
vim.opt.cursorline = false
vim.opt.autoread = true
vim.opt.encoding = 'utf-8'

-- sets tab size to 4 spaces
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
-- converts tabs to spaces
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.autoindent = true
-- highlights searches
vim.opt.hlsearch = true
-- sets default clipboard to use the system clipboard
vim.opt.clipboard = 'unnamedplus'
