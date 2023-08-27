-- slip.notes
--
-- Note's representation
--

local config = require('slip.config')

local Path = require('plenary.path')

local get_note_buf_handle = function (path)
  for _, buf_handle in ipairs(vim.api.nvim_list_bufs()) do
    --TODO: really works with paths?
    if path == vim.api.nvim_buf_get_name(buf_handle) then
      return buf_handle
    end
  end

  return nil
end
local get_slip_of_note = function (path)
  for slip, slip_spec in pairs(config.opts.slips) do
   local slip_path = slip_spec.path

   if string.sub(path, 1, string.len(slip_path)) == slip_path then
     return slip
   end
  end
end

local m = {}

local Note = {
  links_to = {},
  line_nums = {},
}
Note.__index = Note

function Note:new(metadata)
  local note = setmetatable(metadata, self)

  note.valid = note.name ~= nil and note.filename ~= nil and note.slip ~= nil

  if note.valid then
    local bib_dir_name = config.opts.slips[note.slip].bibliography_dir_name
    --TODO rename config opts, is there need for config opts?
    note.type = string.sub(note.filename, 1, string.len(bib_dir_name)) == bib_dir_name and 'bibliographical' or 'permanent'
  end

  return note
end

function Note:insert_link(note)
  local link_target = note.filename
  local link_name = string.match(note.filename, '/?(%w*)%.md')

  if note.type == 'bibliographical' then
    link_name = 'b/' .. link_name
  end

  local new_link_def = true
  for _, l in ipairs(self.links_to) do
    if l.name == link_name then
      new_link_def = false
      break
    end
  end

  if new_link_def then
    local line_num = self.line_nums.links_to or 1
    local link_def = '[' .. link_name .. ']: ' .. link_target
    vim.api.nvim_buf_set_lines(0, line_num - 1, line_num - 1, false, {link_def})
  end

  local link_text = '[' .. note.name .. '][' ..link_name .. ']'

  -- nvim_put changes cursor position no matter what
  -- and also sets the position one column less if pasting at the end of a line
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local row = cursor_pos[1] - 1
  local col = cursor_pos[2]
  vim.api.nvim_buf_set_text(0, row, col, row, col, {link_text})

  -- set the cursor to the last bracket
  vim.api.nvim_feedkeys('2f]', 'n', false)
end

function m.parse(path)
  local slip = get_slip_of_note(path)

  if slip == nil then
    return nil
  end

  local slip_path = config.opts.slips[slip].path

  local md = {}
  md.path = path
  md.filename = string.sub(path, string.len(slip_path) + 2)
  md.slip = slip
  md.links_to = {}
  md.line_nums = {}

  local note_buf_handle = get_note_buf_handle(path)

  if not vim.fn.filereadable(path) and note_buf_handle == nil then
    return nil
  end

  local lines = nil
  if note_buf_handle == nil then
    lines = Path:new(path):readlines()
  else
    lines = vim.api.nvim_buf_get_lines(note_buf_handle, 0, -1, false)
  end

  -- Finds the note's name as the first header
  for line_num, line in ipairs(lines) do
    -- TODO: format of note's metadata to config?
    local name = string.match(line, '^#+%s*(.*)$')

    local link_name, link_target = string.match(line, '^%[([^]]*)%]:%s*(.*%.md)$')

    if name then
      md.name = name
    end

    if link_name and link_target then
      table.insert(md.links_to, {name = link_name, target = link_target})

      if md.line_nums.links_to == nil then
        md.line_nums.links_to = line_num
      end
    end

    -- The header is the last line read
    if md.name then
      break
    end
  end


  return Note:new(md)
end

function m.get_new_note_path(slip, type)
  local slip_spec = config.opts.slips[slip]

  local dir_path = type == 'permanent' and
    slip_spec.path or
    slip_spec.path .. '/' .. slip_spec.bibliography_dir_name

  local name_counter = #vim.fn.glob(dir_path .. '/*.md', false, true)

  local note_path
  repeat
    name_counter = name_counter + 1
    note_path = dir_path .. '/' .. string.format('%06x.md', name_counter)
  until vim.fn.glob(note_path) == '' or name_counter > 1000

  return note_path
end

return m
