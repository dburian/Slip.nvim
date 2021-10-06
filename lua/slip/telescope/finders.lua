-- slip/telescope/pickers
--
-- Defines Telescope finders that interact with slip.nvim
--

local config = require('slip.config')
local notes = require('slip.notes')

local finders = require('telescope.finders')

local m = {}

function m.slip_notes(slips)
  local entries = {}
  for _, slip in ipairs(slips) do
    --todo: do this with one_shot_job and ripgrep or find
    local paths = vim.fn.glob(config.opts.slips[slip].path .. '/**/*.md', false, true)

    for _, path in ipairs(paths) do
      table.insert(entries, notes.parse(path))
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
