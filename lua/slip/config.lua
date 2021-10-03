--[[
Helper module, defines configuration for Slip
]]

local Path = require('plenary.path')

local m = {}

m.opts = {
  slips = {}
}

local set_option = function (opt_spec)
  local trg = opt_spec.target
  local src = opt_spec.source
  local name = opt_spec.name

  local value = src[name] or opt_spec.default

  if value == nil and opt_spec.required then
    error('Option ' .. name .. ' is required, but not specified.')
  end

  if opt_spec.check then
    if opt_spec.check(value) ~= true then
      error('Option ' .. name .. ' is invalid.')
    end
  end

  if opt_spec.transform then
    value = opt_spec.transform(value)
  end

  trg[name] = value
end

local set_slips = function (slips)
  slips = slips or {}
  local slips_conf = m.opts.slips

  for slip, opts in pairs(slips) do
    slips_conf[slip] = {}

    set_option({
      target = slips_conf[slip],
      source = opts,
      name = 'path',
      check = function (path)
        local p_obj = Path:new(path)
        -- Only accepting absolute paths (not completely functional workaround
        -- until I do the pull request)
        return p_obj:is_dir() and p_obj:is_absolute()
      end,
      transform = function (path)
        local expanded = Path:new(path):expand() --Takes care of ~
        return Path:new(expanded):absolute()
      end
    })

    set_option({
        target = slips_conf[slip],
        source = opts,
        name = 'index_filename',
        default = 'index.md',
    })

    set_option({
        target = slips_conf[slip],
        source = opts,
        name = 'name',
        -- TODO: uppercase first letter
        default = slip,
    })

    if m.opts._default_slip == nil then
      m.opts._default_slip = slip
    end
  end
end
local set_opts = function (opts)

  set_option({
    target = m.opts,
    source = opts,
    name = 'default_slip',
  })

end

function m.setup(opts)
  set_slips(opts.slips)
  set_opts(opts)
end

return m
