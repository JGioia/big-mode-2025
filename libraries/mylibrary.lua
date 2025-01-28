-- basic helper functions i've wrote or found on stack overflow

function table.removeKey(t, key)
  for i = 1, #t do
    if t[i] == key then
      table.remove(t, i)
      return
    end
  end
  error("Shape not able to be removed")
end

function table.copy(t)
  -- performs shallow copy
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function table.isValueIn(t, v)
  for _, value in pairs(t) do
    if value == v then
      return true
    end
  end
  return false
end

function DumpObject(o)
  -- converts the object to a string (used for debugging)
  return DumpObjectHelper(o, {})
end

function DumpObjectHelper(o, seenTables)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
       if k == 'self' or table.isValueIn(seenTables, v) then
          goto continue
       end
       if type(k) ~= 'number' then
         k = '"'..k..'"'
       end
       if type(v) == 'table' then
        table.insert(seenTables, v)
       end
       s = s .. '['..k..'] = ' .. DumpObjectHelper(v, seenTables) .. ','
        ::continue::
    end
    return s .. '} '
 else
    return tostring(o)
 end
end