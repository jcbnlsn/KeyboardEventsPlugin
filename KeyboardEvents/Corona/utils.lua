
--====================================================================--
-- Utils.lua
--====================================================================--
local Utils = {}

local rand = math.random
math.randomseed( os.time() )

----------------------------------------
-- Time/date conversion
----------------------------------------
local days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"}

function Utils.timeStringReadable(stamp)
	assert(stamp, "Utils.timeStringReadable() expected a number, got nil")
	local t = os.date("*t", stamp)
	local dateString = days[t.wday].." "..string.format("%.2d:%.2d", t.hour, t.min)
	return dateString or ""
end

-----------------------------------------
-- String split
-----------------------------------------
function Utils.splitString(str, pat)
   local t = {}
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

-----------------------------------------
-- String trim
-----------------------------------------
function Utils.trimString(str)
	assert(str, "utils.trimString() expected a table, got nil")
  	return (str:gsub("^%s*(.-)%s*$", "%1"))
end

-----------------------------------------
-- Clone table
-----------------------------------------
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Utils.cloneTable(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

----------------------------------------
-- Misc
----------------------------------------
function Utils.shuffleTable(t)
    assert(t, "utils.shuffleTable() expected a table, got nil")
    local iterations = #t
    local j
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

return Utils
