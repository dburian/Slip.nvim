--[[
Helper module to operate on files.
]]

local config = require('slip.config')
local dir = require('plenary.scandir')
local m = {}


function m.get_note_filename(opts)
  local scan_dir_opts = {
    hidden = false,
    add_dirs = false,
    respect_gitignore = true,
    depth = 3,
    -- search_pattern = '.*%.md',
    silent = true,
  }
  local taken = dir.scan_dir(config.slips[opts.slip].path, scan_dir_opts)

  --TODO: check if new file does not already exist
  return string.format('%06x.md', #taken + 1)
end

return m
