local Packages = script.Parent.Parent.Parent
local Rodux = require(Packages.Rodux)

return Rodux.createReducer(os.clock(), {
  Refresh = function()
    return os.clock()
  end,
})
