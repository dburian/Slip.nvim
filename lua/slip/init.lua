-- slip
-- Initializes Slip.nvim. Defines the main API.
--

local config = require('slip.config')

local slip = {}

function slip.setup(opts)
  local succ, obj = pcall(config.setup, opts)

  if succ == false then
    vim.cmd('throw \'' .. tostring(obj) .. '\'')
  end
end

return slip
