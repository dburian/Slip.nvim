--
-- slip.actions
--
-- Public functions with unified API.
--

local notes = require('slip.notes')
local slips = require('slip.slips')
local config = require('slip.config').opts
local slip_finders = require('slip.telescope.finders')

local tele_builtin = require('telescope.builtin')
local pickers = require('telescope.pickers')
local actions = require('telescope.actions')
local action_set = require('telescope.actions.set')
local action_state = require('telescope.actions.state')
local tele_conf = require('telescope.config').values

local m = {}

function m.create_note(opts)
  opts = opts or {}
  opts.slip = opts.slip or slips.get_default()
  opts.type = opts.type or 'permanent'


  if opts.type == 'bibliographical' then
    local slip_spec = config.slips[opts.slip]
    local bib_dir_path = slip_spec.path .. '/' .. slip_spec.bibliography_dir_name

    if 0 == vim.fn.isdirectory(bib_dir_path) then
      print('succ: ' .. vim.fn.mkdir(bib_dir_path))
    end
  end

  local path = notes.get_new_note_path(opts.slip, opts.type)

  local edit_cmd = opts.edit_cmd or 'edit'
  vim.cmd(edit_cmd .. ' ' .. vim.fn.fnamemodify(path, ':~:.'))
end

function m.update_index(opts)
  opts = opts or {}
  opts.slips = opts.slips or {slips.get_default()}

  local notes_to_update = {}

  local add_all_notes = function (slip)
    local notes_paths = vim.fn.glob(config.slips[slip].path .. '/*.md', false, true)

    if #notes_paths > 0 then
      notes_to_update[slip] = {}
    end

    for _, path in ipairs(notes_paths) do
      table.insert(notes_to_update[slip], notes.parse(path))
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

  pickers.new(opts, {
    prompt_title = 'Notes in ' .. table.concat(opts.slips, '/'),
    finder = slip_finders.slip_notes(opts.slips),
    previewer = tele_conf.file_previewer(opts),
    sorter = tele_conf.generic_sorter(opts),
  }):find()
end

--TODO: transform these into pickers with opts
function m.insert_link(opts)
  opts = opts or {}
  opts.slip = opts.slip or slips.get_default()

  local curr_note = notes.parse(vim.fn.expand('%:p'))
  if curr_note == nil then
    error('Path ' .. vim.fn.expand('&:p') .. ' cannot be parsed as a note.')
  end

  local curr_mode = vim.api.nvim_get_mode().mode

  if curr_note == nil then
    error('Cannot insert link. Current file is not a note.')
  end

  pickers.new(opts, {
    prompt_title = 'Link destination',
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

function m.live_grep(opts)
  opts = opts or {}
  opts.slips = opts.slips or {slips.get_default()}

  local search_dirs = {}
  for _, s in ipairs(opts.slips) do
    table.insert(search_dirs, config.slips[s].path)
  end

  tele_builtin.live_grep(vim.tbl_extend('keep', opts, {
    prompt_title = 'Notes live grep in ' .. table.concat(opts.slips, '/'),
    search_dirs = search_dirs,
  }))
end

function m.find_close_notes(opts)
  opts = opts or {}
  opts.note_path = opts.note_path or vim.fn.exepath('%:p')

  local central_note = notes.parse(vim.fn.expand('%:p'))
  if central_note == nil then
    error('Path ' .. vim.fn.expand('&:p') .. ' cannot be parsed as a note.')
  end

end

return m
