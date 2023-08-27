--- Slip.nvim plugin for managing slip boxes
--


vim.cmd[[
command! -nargs=* Slip lua require'slip'execute_command(<args>)
]]
