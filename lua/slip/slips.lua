-- slip.slips
--
-- Code to manage slips
--

local config = require('slip.config')

local Path = require('plenary.path')

local m = {}

-- Represents slip's index file
-- It is not guaranteed to correspond with the actual file,
-- to ensure equality call Index.write
local Index = {}
Index.__index = Index

function Index:new(metadata)
  local index = setmetatable(metadata, self)

  return index
end

function Index:write()
  local lines = {}

  table.insert(lines, '# ' .. self.name)
  table.insert(lines, '')

  for _, leaf in ipairs(self.leaves) do
    table.insert(lines, string.format('1. [%s][%s]', leaf.name, leaf.target))
  end

  for idx, line in ipairs(lines) do
    print(string.format('%s %i', line, idx))
  end

  local path = Path:new(self.path)
  path:write(table.concat(lines, '\n'), 'w')
end

function Index:update(slip_notes)
  -- TODO: maybe filtering based on rev_refs could be faster

  -- filter out inner nodes from leaves
  local inner_node_filenames = {}

  for _, n in ipairs(slip_notes) do
    for _, link in ipairs(n.links_to) do
      inner_node_filenames[link.target] = true
    end
  end

  self.leaves = {}
  for _, n in ipairs(slip_notes) do
    if not inner_node_filenames[n.filename] then
      table.insert(self.leaves, {name = n.name, target = n.filename})
    end
  end

  for _, leaf in ipairs(self.leaves) do
    print(leaf.target)
  end

  self:write()
end

local parse_index = function (index_path)
  local md = {
    leaves = {},
    path = index_path:absolute(),
  }

  for _, line in ipairs(index_path:readlines()) do
    local name = line:match('^#+%s*(.*)$')
    local leaf_name, leaf_target = line:match('^%d%.+%s*%[([^]]*)%]%[([^]]*)%]$')

    if name then
      md.name = name
    end

    if leaf_name and leaf_target then
      table.insert(md.leaves, {
        name = leaf_name,
        target = leaf_target
      })
    end
  end

  return Index:new(md)
end

function m.get_current()
  local paths_to_match = {}
  table.insert(paths_to_match, vim.fn.getcwd())
  table.insert(paths_to_match, vim.fn.expand('%:p'))

  local match_path = function (path)
    for slip, slip_spec in pairs(config.opts.slips) do
      if path:sub(1, #slip_spec.path) == slip_spec.path then
        return slip
      end
    end

    return nil
  end

  local matched_slip = nil
  for _, path in ipairs(paths_to_match) do
    matched_slip = match_path(path)
    if matched_slip ~= nil then
      break
    end
  end

  return matched_slip
end

function m.get_default()
  return m.get_current() or config.opts.default_slip or config.opts._default_slip
end

function m.get_index(slip)
  local slip_spec = config.opts.slips[slip]
  local index_filename = slip_spec.index_filename

  local index_path = Path:new(slip_spec.path, index_filename)

  if not index_path:exists() then
    -- if index does note exist return an empty one
    return Index:new({
      name = slip_spec.name .. '\'s index',
      path = index_path:absolute(),
      leaves = {}
    })
  end

  return parse_index(index_path)
end

return m
