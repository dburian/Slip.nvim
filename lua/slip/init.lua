--[[
Initializes Slip.nvim. Defines the main API.
]]

local config = require('slip.config')
local files = require('slip.files')
local Path = require('plenary.path')

local uv = vim.loop

local slip = {}

function slip.setup(opts)
  config.set_slips(opts.slips)
  config.set_global_opts(opts.global)
end

function slip.new_note(opts)
  opts = opts or {}
  opts.slip = opts.slip or config.global.default_slip

  local filename = opts.get_note_filename and
    opts.get_note_filename(opts) or
    files.get_note_filename(opts)

  local slip_path = config.slips[opts.slip].path
  local path = Path:new(slip_path, filename)

  vim.cmd('edit ' .. path:normalize(uv.cwd()))
end

return slip
