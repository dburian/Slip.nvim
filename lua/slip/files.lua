-- slip.files
-- Helper module operating on files and with filesystems
--

local config = require('slip.config')

local dir = require('plenary.scandir')
local Path = require('plenary.path')

local m = {}

function m.scan_slip(slip)
  local scan_dir_opts = {
    hidden = false,
    add_dirs = false,
    respect_gitignore = true,
    depth = 1,
    search_pattern = '.*%.md',
    silent = true,
  }

  local slip_path = config.opts.slips[slip].path
  local paths = dir.scan_dir(slip_path, scan_dir_opts)
  local filenames = {}
  for _, path in ipairs(paths) do
    local filename = vim.fn.fnamemodify(path, ':p:t')

    if filename ~= config.opts.slips[slip].index_filename then
      table.insert(filenames, filename)
    end
  end

  return filenames
end

function m.get_new_note_path(slip)
  local taken = m.scan_slip(slip)

  local name_counter = #taken
  local slip_path = config.opts.slips[slip].path
  local note_path
  repeat
    name_counter = name_counter + 1
    note_path = Path:new(slip_path, string.format('%06x.md', name_counter))
  until not note_path:exists()

  return note_path
end

return m
