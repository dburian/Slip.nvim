--[[
Helper module, defines configuration for Slip
]]

local m = {}
m.slips = {}
m.global = {}


local set_options = function(target, source, defaults, required, opt_name)
  for k, v in pairs(source) do
    target[k] = source[k]
  end

  for k, def_value in pairs(defaults) do
    target[k] = target[k] or def_value
  end

  for _, req_key in ipairs(required) do
    assert(
      target[req_key] ~= nil,
      'Property ' .. req_key .. ' is required in setup of ' .. opt_name .. '.'
    )
  end
end



function m.set_slips(slips)
  assert(slips ~= nil, '\'slips\' is a required option.')

  for slip_key, slip_opts in pairs(slips) do
    m.slips[slip_key] = {}

    set_options(
      m.slips[slip_key],
      slip_opts,
      {},
      {'path'},
      'a slip-box ' .. slip_key
    )
  end
end

function m.set_global_opts(opts)
  opts = opts or {}

  local default_slip_key = nil
  for k in pairs(m.slips) do
    default_slip_key = k
    break
  end

  set_options(
    m.global,
    opts,
    {default_slip = default_slip_key},
    {'default_slip'},
    'global options'
  )
end

return m
