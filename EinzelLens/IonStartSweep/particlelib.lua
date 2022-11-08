--[[
 Particle utilities.
 D.Manura, 2012-05.
--]]

local PL = {}

--[[
 Reloads particle definitions from FLY2 file.
 WARNING: These use currently undocumented functions.
 Currently, this must be called from segment.flym not segment.initialize_run.
 `var` (if not nil) is table of variables that will be passed to the
   FLY2 file, which can access `var` as a global.
 This approach currently works only with .FLY2 files, not .ION files.
--]]
function PL.reload_fly2(filename, var)
  local key
  for k,v in pairs(debug.getregistry()) do
    if type(v)=='table' and v.iterator then key = k; break end
  end
  assert(key)
  local ok, err = xpcall(function()
    _G.var = var -- set vars
    debug.getregistry()[key] = simion.iob2.load_fly2_file(filename)
  end, debug.traceback)
  _G.var = nil -- clear (the pcall ensures this is always executed.
  if not ok then error(err) end
end

return PL

