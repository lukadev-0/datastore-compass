local Packages = script.Parent.Parent.Parent
local Rodux = require(Packages.Rodux)

return Rodux.createReducer(nil, {
  SelectKey = function(_, action)
    return action.key
  end,
})
