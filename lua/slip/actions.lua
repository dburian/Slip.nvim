--
-- slip.actions
--
-- Public functions with unified API.
--

local notes = require('slip.notes')
local slips = require('slip.slips')
local files = require('slip.files')
local slip_finders = require('slip.telescope.finders')

local pickers = require('telescope.pickers')
local actions = require('telescope.actions')
local action_set = require('telescope.actions.set')
local action_state = require('telescope.actions.state')
local tele_conf = require('telescope.config').values

local m = {}

function m.create_note(opts)
  opts = opts or {}
  opts.slip = opts.slip or slips.get_default()

  local path = files.get_new_note_path(opts.slip)

  local edit_cmd = opts.edit_cmd or 'edit'
  vim.cmd(edit_cmd .. ' ' .. path:normalize(vim.fn.getcwd()))
end

function m.update_index(opts)
  opts = opts or {}
  opts.slips = opts.slips or {slips.get_default()}

  local notes_to_update = {}

  local add_all_notes = function (slip)
    local slips_notes = files.scan_slip(slip)

    if #slips_notes > 0 then
      notes_to_update[slip] = {}
    end

    for _, filename in ipairs(slips_notes) do
      table.insert(notes_to_update[slip], notes.parse(slip, filename))
    end
  end

  for _, slip in ipairs(opts.slips) do
    add_all_notes(slip)
  end

  for slip, slip_notes in pairs(notes_to_update) do
    local index = slips.get_index(slip)
    index:update(slip_notes)
  end
end

function m.find_notes(opts)
  opts = opts or {}
  opts.slips = opts.slips or {slips.get_default()}

  pickers.new({
      finder = slip_finders.slip_notes(opts.slips),
      previewer = tele_conf.file_previewer(opts),
      sorter = tele_conf.generic_sorter(opts),
  }):find()
end

--TODO: transform these into pickers with opts
function m.insert_link(opts)
  opts = opts or {}
  opts.slip = opts.slip or slips.get_default()

  local curr_note = notes.parse(slips.get_current(), vim.fn.expand('%:p:t'))
  local curr_mode = vim.api.nvim_get_mode().mode

  if curr_note == nil then
    error('Cannot insert link. Current file is not a note.')
  end

  pickers.new({
      finder = slip_finders.slip_notes({opts.slip}),
      previewer = tele_conf.file_previewer(opts),
      sorter = tele_conf.generic_sorter(opts),
      attach_mappings = function (prompt_bufnr)
        action_set.select:replace(function ()
          actions.close(prompt_bufnr)
          local selected_note = action_state.get_selected_entry().value

          curr_note:insert_link(selected_note)

          if curr_mode == 'i' then
            vim.api.nvim_feedkeys('a', 'n', true)
          end
        end)

        return true
      end
  }):find()
end

return m
