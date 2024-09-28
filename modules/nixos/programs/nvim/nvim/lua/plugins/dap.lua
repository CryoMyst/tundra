local dap, dapui = require("dap"), require("dapui")

dap.adapters.coreclr = {
  type = 'executable',
  args = {'--interpreter=vscode'}
}

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
        return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end,
  },
}

dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
    dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

vim.keymap.set('n', '<leader>dc', dap.continue, {})
vim.keymap.set('n', '<leader>dd', dap.disconnect, {})
vim.keymap.set('n', '<leader>de', dap.set_exception_breakpoints, {})
vim.keymap.set('n', '<leader>di', dap.step_into, {})
vim.keymap.set('n', '<leader>do', dap.step_over, {})
vim.keymap.set('n', '<leader>dr', dap.repl.open, {})
vim.keymap.set('n', '<leader>ds', dap.stop, {})
vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint, {})
vim.keymap.set('n', '<leader>du', dap.step_out, {})
vim.keymap.set('n', '<leader>dv', dapui.toggle, {})

