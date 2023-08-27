-- slip
-- Initializes Slip.nvim. Defines the main API.
--

local config = require('slip.config')

local slip = {}

function slip.setup(opts)
  local succ, obj = pcall(config.setup, opts)

  if succ == false then
    print('Slip.nvim error: \'' .. tostring(obj) .. '\'')
  end
end

function slip.execute_command(...)
  for _, a in ipairs(arg) do
    print(a)
  end
end

return slip
