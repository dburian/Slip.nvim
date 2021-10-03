-- slip/telescope/pickers
--
-- Defines Telescope finders that interact with slip.nvim
--

local files = require('slip.files')
local notes = require('slip.notes')

local finders = require('telescope.finders')

local m = {}

function m.slip_notes(slips)
  local entries = {}
  for _, slip in ipairs(slips) do
    local filenames = files.scan_slip(slip)

    for _, f in ipairs(filenames) do
      table.insert(entries, notes.parse(slip, f))
    end
  end

  return finders.new_table({
    results = entries,
    entry_maker = function (note)
      return {
        value = note,
        display = note.slip .. '/' .. note.filename .. ' ' .. (note.name or 'no-name'),
        path = note.path,
        ordinal = note.name,
      }
    end
  })
end

return m
