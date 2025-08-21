-- 使用相对行号
vim.wo.relativenumber = true
-- 搜索大小写不敏感，除非包含大写
vim.o.ignorecase = true
vim.o.smartcase = true
-- 搜索高亮
vim.o.hlsearch = true
-- 自动跳转到第一个匹配的结果
vim.o.incsearch = true
-- 绑定按键取消高亮
vim.api.nvim_set_keymap("n", "<Esc> <Esc>", ":nohlsearch<CR>", { noremap = true, silent = true })
-- 添加系统剪贴版设置
vim.o.clipboard = "unnamedplus"
