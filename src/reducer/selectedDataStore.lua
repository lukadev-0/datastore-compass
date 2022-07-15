local Packages = script.Parent.Parent.Parent
local Rodux = require(Packages.Rodux)

return Rodux.createReducer(nil, {
  SelectDataStore = function(_, action)
    return action.dataStore
  end,
})
