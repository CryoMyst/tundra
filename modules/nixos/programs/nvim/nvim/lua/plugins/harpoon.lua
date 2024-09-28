local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file, {})
vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu, {})

-- vim.keymap.set("n", "<leader>1", ui.nav_file(1), {})
-- vim.keymap.set("n", "<leader>2", ui.nav_file(2), {})
-- vim.keymap.set("n", "<leader>3", ui.nav_file(3), {})
-- vim.keymap.set("n", "<leader>4", ui.nav_file(4), {})