require("nvim-tree").setup()

vim.keymap.set('n', '<leader>tt', ':NvimTreeToggle<CR>', { noremap = true, silent = true })