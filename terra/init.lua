-- Copyright 2007-2016 Mitchell mitchell.att.foicica.com. See LICENSE.
-- Edited by Rok github@rokf

local M = {}

--[[ This comment is for LuaDoc.
---
-- The terra module.
-- It provides utilities for editing Terra code.
module('_M.terra')]]

-- Autocompletion and documentation.

---
-- List of "fake" ctags files to use for autocompletion.
-- The kind 'm' is recognized as a module, 'f' as a function, 't' as a table and
-- 'F' as a module or table field.
-- @class table
-- @name tags

M.tags = { _USERHOME..'/modules/terra/tags' }
-- I've removed:'_HOME..'/modules/terra/tags'

---
-- Map of expression patterns to their types.
-- Expressions are expected to match after the '=' sign of a statement.
-- @class table
-- @name expr_types
-- @usage _M.lua.expr_types['^spawn%b()%s*$'] = 'proc'
M.expr_types = {['^[\'"]'] = 'string', ['^io%.p?open%s*%b()%s*$'] = 'file'}

local XPM = textadept.editing.XPM_IMAGES
local xpms = {m = XPM.CLASS, f = XPM.METHOD, F = XPM.VARIABLE, t = XPM.TYPEDEF}

textadept.editing.autocompleters.terra = function()
  local list = {}
  -- Retrieve the symbol behind the caret.
  local line, pos = buffer:get_cur_line()
  local symbol, op, part = line:sub(1, pos):match('([%w_%.]-)([%.:]?)([%w_]*)$')
  if symbol == '' and part == '' and op ~= '' then return nil end -- lone .
  symbol, part = symbol:gsub('^_G%.?', ''), part ~= '_G' and part or ''
  -- Attempt to identify string type and file type symbols.
  local buffer = buffer
  local assignment = '%f[%w_]'..symbol:gsub('(%p)', '%%%1')..'%s*=%s*(.*)$'
  for i = buffer:line_from_position(buffer.current_pos) - 1, 0, -1 do
    local expr = buffer:get_line(i):match(assignment)
    if expr then
      for patt, type in pairs(M.expr_types) do
        if expr:find(patt) then symbol = type break end
      end
    end
  end
  
  -- Search through ctags for completions for that symbol.
  local name_patt = '^'..part
  local sep = string.char(buffer.auto_c_type_separator)
  for i = 1, #M.tags do -- for each fake ctags file
    if lfs.attributes(M.tags[i]) then
      for tag_line in io.lines(M.tags[i]) do
        local name = tag_line:match('^%S+')
        if name:find(name_patt) and not list[name] then
          local fields = tag_line:match(';"\t(.*)$')
          local k, class = fields:sub(1, 1), fields:match('class:(%S+)') or ''
          if class == symbol and (op ~= ':' or k == 'f') then
            list[#list + 1] = ("%s%s%d"):format(name, sep, xpms[k])
            list[name] = true
          end
        end
      end
    end
  end
  return #part, list
end

textadept.editing.api_files.terra = {
  _USERHOME..'/modules/terra/api'
}
-- Removed:_HOME..'/modules/terra/api',

-- Commands.

---
-- Container for Terra-specific key bindings.
-- @class table
-- @name _G.keys.terra
keys.lua = {}

-- Snippets.

if type(snippets) == 'table' then
---
-- Container for Terra-specific snippets.
-- @class table
-- @name _G.snippets.terra
  snippets.terra = {
    ['func'] = 'function %1(name)(%2(args))\n\t%0\nend',
    ['terra'] = 'terra %1(name)(%2(args))\n\t%0\nend',
    ['if'] = 'if %1 then\n\t%0\nend',
    ['eif'] = 'elseif %1 then\n\t',
    ['for'] = 'for %1(i) = %2(1), %3(10)%4(, %5(-1)) do\n\t%0\nend',
    ['forp'] = 'for %1(k), %2(v) in pairs(%3(t)) do\n\t%0\nend',
    ['fori'] = 'for %1(i), %2(v) in ipairs(%3(t)) do\n\t%0\nend',
    ['while'] = 'while %1 do\n\t%0\nend',
    ['repeat'] = 'repeat\n\t%0\nuntil %1',
    ['do'] = 'do\n\t%0\nend',
  }
end

return M
